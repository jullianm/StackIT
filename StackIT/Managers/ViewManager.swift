//
//  ViewModel.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-07-25.
//

import Combine
import Foundation
import StackAPI

class ViewManager: ObservableObject {
    /// Published properties
    @Published var tags: [TagSummary] = TagSummary.popular
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
    private var proxy: ViewManagerProxy
    
    /// Public properties
    var cachedQuestions: [QuestionsSummary] = []

    /// Subjects properties
    var resetAllSubject = PassthroughSubject<Void, Never>()
    var fetchTagsSubject = PassthroughSubject<AppSection, Never>()
    var fetchQuestionsSubject = CurrentValueSubject<AppSection, Never>(.questions)
    var fetchAnswersSubject = CurrentValueSubject<AppSection, Never>(.questions)
    var fetchAccountSectionSubject = PassthroughSubject<AppSection, Never>()
    var authenticationSubject = CurrentValueSubject<AppSection, Never>(.authentication(action: .checkAuthentication))
    
    init(authenticationManager: AuthenticationManager = .shared, enableMock: Bool = false) {
        authManager = authenticationManager
        proxy = ViewManagerProxy(api: .init(enableMock: enableMock))
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
        proxy.fetchTags()
            .map { [weak self] _ -> AnyPublisher<[TagSummary], Never> in
                guard let self = self else { return Just([]).eraseToAnyPublisher() }
                return self.proxy.fetchTags()
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
            .map { [self] section -> AnyPublisher<[QuestionsSummary], Never> in
                guard case let .questions(subsection, action) = section else {
                    fatalError()
                }
                
                print(action)
                
                switch subsection {
                case .search(let keywords):
                    let outputEvent: (Search) -> Void = { [weak self] in
                        self?.showLoadMore = $0.hasMore
                    }
                    
                    return proxy.fetchQuestionsByKeywords(keywords: keywords,
                                                          action: action,
                                                          outputEvent: outputEvent)
                case let .trending(trending):
                    let outputEvent: (Questions) -> Void = { [weak self] in
                        self?.showLoadMore = $0.hasMore && $0.quotaRemaining > 0
                    }
                    
                    return proxy.fetchQuestionsWithFilters(tags: [],
                                                           trending: trending,
                                                           action: action,
                                                           outputEvent: outputEvent)
                case .tag:
                    let outputEvent: (Questions) -> Void = { [weak self] in
                        self?.showLoadMore = $0.hasMore && $0.quotaRemaining > 0
                    }
                    
                    return proxy.fetchQuestionsWithFilters(tags: tags.filter(\.isFavorite).map(\.name),
                                                           trending: .votes,
                                                           action: action,
                                                           outputEvent: outputEvent)
                }
            }
            .switchToLatest()
            .assign(to: \.questionsSummary, on: self)
            .store(in: &subscriptions)
    }
    
    private func bindFetchAnswers() {
        fetchAnswersSubject
            .dropFirst()
            .handleEvents(receiveOutput: handleOutputSectionEvent)
            .map { [self] section -> AnyPublisher<[AnswersSummary], Never> in
                guard case let .answers(question, _) = section else {
                    return Just([]).eraseToAnyPublisher()
                }
                
                return proxy.fetchAnswersByQuestionId(question.questionId)
            }
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
                        /// ⚠️ We already have current user informations in `User` object.
                        return
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
                        self.proxy.fetchInbox()
                            .handleEvents(receiveOutput: { [weak self] _ in
                                self?.loadingSections.remove(.inbox)
                            })
                            .assign(to: \.inbox, on: self)
                            .store(in: &self.subscriptions)
                    case .timeline:
                        self.proxy.fetchTimeline()
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
                self.proxy.stackConfig = self.authManager.stackConfig
                self.loadingSections.remove(.account)
            })
            .assign(to: \.user, on: self)
            .store(in: &subscriptions)
    }
}


// MARK: - Webservice helpers
extension ViewManager {
    private func handleOutputSectionEvent(output: AppSection) {
        switch output {
        case let .questions(subsection, action):
            handleQuestionsSubsection(subsection, action: action)
        case .answers(let question, _):
            questionsSummary.first(where: \.isSelected)?.setSelected(false)
            questionsSummary.first(where: { $0.id == question.id })?.setSelected(true)
            loadingSections.insert(.answers)
        default:
            break
        }
    }
    
    private func handleQuestionsSubsection(_ subsection: SubSection, action: Action?) {
        if action == nil { answersSummary = [] }
        loadingSections.insert(.questions)
        
        switch subsection {
        case .tag(let tag) where action == nil:
            tags.first(where: { $0.name == tag.name })?.isFavorite.toggle()
        case .search:
            tags.forEach { $0.isFavorite = false }
        default:
            break
        }
    }
}
