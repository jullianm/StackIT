//
//  ViewModel.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-07-25.
//

import Combine
import Foundation

class ViewManager: ObservableObject {
    /// Published properties
    @Published var tags: [Tag] = Tag.popular
    @Published var questionsSummary: [QuestionsSummary] = QuestionsSummary.placeholders
    @Published var questionsFilter: Set<QuestionsFilter> = []
    @Published var answersSummary: [AnswersSummary] = []
    @Published var loadingSections: Set<LoadingSection> = []
    @Published var showLoadMore: Bool = false
    @Published var user: UserSummary?
    @Published var inbox: [UserMessageSummary] = []
    @Published var timeline: [TimelineSummary] = []

    /// Private properties
    private var subscriptions = Set<AnyCancellable>()
    private var authManager: AuthenticationManager
    private var networkProxy: NetworkManagerProxy
    
    /// Public properties
    var cachedQuestions: [QuestionsSummary] = []

    /// Subjects properties
    var resetAllSubject = PassthroughSubject<Void, Never>()
    var fetchTagsSubject = PassthroughSubject<AppSection, Never>()
    var fetchQuestionsSubject = CurrentValueSubject<AppSection, Never>(.questions)
    var fetchAnswersSubject = CurrentValueSubject<AppSection, Never>(.questions)
    var fetchAccountSectionSubject = PassthroughSubject<AppSection, Never>()
    var authenticationSubject = CurrentValueSubject<AppSection, Never>(.authentication(action: .checkAuthentication))
    
    init(serviceManager: ServiceManager = NetworkManager(), authenticationManager: AuthenticationManager = .shared) {
        authManager = authenticationManager
        networkProxy = .init(serviceManager: serviceManager)
        setupBindings()
    }
    
    private func setupBindings() {
        bindFetchTags()
        bindFetchQuestions()
        bindFetchAnswers()
        bindAuthentication()
        bindFetchAccount()
        bindResetAll()
    }
    
    private func bindResetAll() {
        resetAllSubject
            .sink { [weak self] _ in
                self?.answersSummary = []
                self?.tags.forEach { $0.isFavorite = false }
                self?.fetchQuestionsSubject.send(AppSection.questions)
            }.store(in: &subscriptions)
    }
    
    func updateQuestionsFilter(_ filter: QuestionsFilter) {
        if questionsFilter.contains(filter) {
            questionsFilter.remove(filter)
        } else {
            questionsFilter.insert(filter)
        }
        
        let filteredQuestions = questionsFilter.isEmpty ?
            cachedQuestions:
            cachedQuestions.filtered(by: questionsFilter)
        
        questionsSummary = filteredQuestions.isEmpty ? QuestionsSummary.empty: filteredQuestions
    }
}

// MARK: - Posts-related bindings
extension ViewManager {
    private func bindFetchTags() {
        networkProxy.fetchTags()
            .map { [weak self] _ -> AnyPublisher<[Tag], Never> in
                guard let self = self else { return Just([]).eraseToAnyPublisher() }
                return self.networkProxy.fetchTags()
            }
            .switchToLatest()
            .handleEvents(receiveSubscription: { [weak self] _ in
                self?.loadingSections.insert(.tags)
            }, receiveOutput: { [weak self] _ in
                self?.loadingSections.remove(.tags)
            })
            .assign(to: \.tags, on: self)
            .store(in: &subscriptions)
    }
    
    private func bindFetchQuestions() {
        fetchQuestionsSubject
            .dropFirst()
            .handleEvents(receiveOutput: handleOutputSectionEvent)
            .debounce(for: .seconds(2), scheduler: DispatchQueue.main)
            .map(resolveQuestionsEndpointCall)
            .switchToLatest()
            .assign(to: \.questionsSummary, on: self)
            .store(in: &subscriptions)
    }
    
    private func bindFetchAnswers() {
        fetchAnswersSubject
            .dropFirst()
            .handleEvents(receiveOutput: handleOutputSectionEvent)
            .map(resolveEndpointType)
            .map(networkProxy.fetchAnswers(endpoint:))
            .switchToLatest()
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.loadingSections.remove(.answers)
            })
            .replaceError(with: [])
            .assign(to: \.answersSummary, on: self)
            .store(in: &subscriptions)
    }
}

// MARK: - Account-related bindings
extension ViewManager {
    private func bindFetchAccount() {
        fetchAccountSectionSubject
            .handleEvents(receiveOutput: { [weak self] section in
                switch section {
                case .account(let subsection):
                    switch subsection {
                    case .messages:
                        self?.loadingSections.insert(.inbox)
                    case .timeline:
                        self?.loadingSections.insert(.timeline)
                    case .profile:
                        return /// ⚠️ We already have current user informations in `User` object.
                    }
                default:
                    return
                }
            })
            .sink { [weak self] section in
                guard let self = self else { return }
                
                switch section {
                case .account(let subsection):
                    switch subsection {
                    case .messages:
                        self.networkProxy.fetchInbox()
                            .handleEvents(receiveOutput: { [weak self] _ in
                                self?.loadingSections.remove(.inbox)
                            })
                            .assign(to: \.inbox, on: self)
                            .store(in: &self.subscriptions)
                    case .timeline:
                        self.networkProxy.fetchTimeline()
                            .handleEvents(receiveOutput: { [weak self] _ in
                                self?.loadingSections.remove(.timeline)
                            })
                            .assign(to: \.timeline, on: self)
                            .store(in: &self.subscriptions)
                    case .profile:
                        return
                    }
                default:
                    return
                }
            }.store(in: &subscriptions)
    }
    
    private func bindAuthentication() {
        authenticationSubject
            .sink { [weak self] section in
                switch section {
                case .authentication(let action):
                    switch action {
                    case .checkAuthentication:
                        self?.authManager.checkTokenSubject.send(())
                        self?.loadingSections.insert(.account)
                    case .signIn(let url):
                        self?.authManager.parseTokenSubject.send(url)
                        self?.loadingSections.insert(.account)
                    case .logOut:
                        self?.authManager.removeUserSubject.send(())
                    }
                default:
                    break
                }
                
            }.store(in: &subscriptions)
        
        authManager.addUserPublisher
            .handleEvents(receiveOutput: { [weak self] _ in
                guard let self = self else { return }
                self.networkProxy.stackConfig = self.authManager.stackConfig
                self.loadingSections.remove(.account)
            })
            .assign(to: \.user, on: self)
            .store(in: &subscriptions)
    }
}


// MARK: - Webservice helpers
extension ViewManager {
    private func resolveQuestionsEndpointCall(from output: AppSection) -> AnyPublisher<[QuestionsSummary], Never> {
        switch output {
        case .questions(let subsection, let status):
            switch subsection {
            case .search(let keywords):
                return networkProxy.fetchQuestionsByKeywords(keywords: keywords,
                                                             status: status,
                                                             filteredBy: questionsFilter)
            default:
                let handleOutputEvent: (Questions) -> Void = { [weak self] in
                    self?.showLoadMore = $0.hasMore && $0.quotaRemaining > 0
                }
                return networkProxy.fetchQuestions(endpoint: resolveEndpointType(from: output),
                                                   filteredBy: questionsFilter,
                                                   onOutputReceived: handleOutputEvent)
            }
            
        default:
            assertionFailure("⚠️ We should not fall into that case.")
            return Just([]).eraseToAnyPublisher()
        }
    }
    
    private func resolveEndpointType(from output: AppSection) -> Endpoint {
        switch output {
        case let .questions(subsection, status):
            switch subsection {
            case let .trending(trending):
                return .questions(subendpoint: .questionsByFilters(tags: [],
                                                                   trending: trending,
                                                                   status: status))
            case .tag:
                return .questions(subendpoint: .questionsByFilters(tags: tags.filter(\.isFavorite),
                                                                   trending: .votes,
                                                                   status: status))
            case let .search(keywords):
                return .questions(subendpoint: .questionsByKeywords(keywords,
                                                                    status: status))
            }
        case let .answers(question, _):
            return .answers(subendpoint: .answersByQuestionId(question.questionId))
        default:
            assertionFailure("⚠️ We should not fall into that case.")
            return .tags
        }
    }
    
    private func handleOutputSectionEvent(output: AppSection) {
        switch output {
        case let .questions(subsection, status):
            handleQuestionsSubsection(subsection, status: status)
        case .answers(let question, _):
            questionsSummary.first(where: \.isSelected)?.setSelected(false)
            questionsSummary.first(where: { $0.id == question.id })?.setSelected(true)
            loadingSections.insert(.answers)
        default:
            break
        }
    }
    
    private func handleQuestionsSubsection(_ subsection: SubSection, status: SectionStatus) {
        if status == .active { answersSummary = [] }
        loadingSections.insert(.questions)
        
        switch subsection {
        case .tag(let tag) where status == .active:
            tags.first(where: { $0.name == tag.name })?.isFavorite.toggle()
        case .search:
            tags.forEach { $0.isFavorite = false }
        default:
            break
        }
    }
}
