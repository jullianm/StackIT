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

    /// Private properties
    private var serviceManager: ServiceManager
    private var authenticationManager: AuthenticationManager
    private var subscriptions = Set<AnyCancellable>()
    
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
//        #if DEBUG
//        self.serviceManager = MockManager()
//        #else
        self.serviceManager = serviceManager
//        #endif
        self.authenticationManager = authenticationManager
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
        fetchTags()
            .map { [weak self] _ -> AnyPublisher<[Tag], Never> in
                guard let self = self else { return Just([]).eraseToAnyPublisher() }
                return self.fetchTags()
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
            .map(fetchAnswers(endpoint:))
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
                    case .activity:
                        self?.loadingSections.insert(.activity)
                    case .profile:
                        return /// ⚠️ We already have current user informations in `User` object.
                    }
                default:
                    break
                }
            })
            .sink { [weak self] section in
                switch section {
                case .account(let subsection):
                    switch subsection {
                    case .messages:
                        self?.fetchInbox()
                    case .activity:
                        break /// ⚠️  To do.
                    case .profile:
                        return /// ⚠️ We already have current user informations in `User` object.
                    }
                default:
                    break
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
                        self?.authenticationManager.checkTokenSubject.send(())
                        self?.loadingSections.insert(.account)
                    case .signIn(let url):
                        self?.authenticationManager.parseTokenSubject.send(url)
                        self?.loadingSections.insert(.account)
                    case .logOut:
                        self?.authenticationManager.removeUserSubject.send(())
                    }
                default:
                    break
                }
                
            }.store(in: &subscriptions)
        
        authenticationManager.addUserPublisher
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.loadingSections.remove(.account)
            })
            .assign(to: \.user, on: self)
            .store(in: &subscriptions)
    }
}

// MARK: - Webservices call
extension ViewManager {
    private func fetchTags() -> AnyPublisher<[Tag], Never> {
        return serviceManager.fetch(endpoint: .tags, model: Tags.self)
            .map { $0.items.map(\.name).map { Tag(name: $0) } }
            .replaceError(with: Tag.popular)
            .eraseToAnyPublisher()
    }
    
    private func fetchQuestions(endpoint: Endpoint) -> AnyPublisher<[QuestionsSummary], Never> {
        return serviceManager.fetch(endpoint: endpoint, model: Questions.self)
            .handleEvents(receiveOutput: { [weak self] questions in
                self?.showLoadMore = questions.hasMore && questions.quotaRemaining > 0
            })
            .map { [weak self] questions -> AnyPublisher<(Questions, Comments), Error> in
                guard let self = self else { return Just((.empty, .empty)).setFailureType(to: Error.self).eraseToAnyPublisher() }
                
                let ids = questions.items.map(\.questionId).joinedString()
                let commentsPublisher = self.serviceManager.fetch(endpoint: .comments(subendpoint: .commentsByQuestionsIds(ids)), model: Comments.self)
                let questionsPublisher = Just(questions).setFailureType(to: Error.self).eraseToAnyPublisher()
                
                return Publishers.CombineLatest(questionsPublisher, commentsPublisher).eraseToAnyPublisher()
            }
            .switchToLatest()
            .map { (questions, comments) -> [QuestionsSummary] in
                return questions.items.map { question in
                    let comments = comments.items.filter { $0.postId == question.questionId }.map(CommentsSummary.init)
                    return QuestionsSummary(from: question, comments: comments)
                }
            }
            .replaceError(with: [])
            .map { [weak self] in
                guard let self = self else { return [] }
                return $0.filtered(by: self.questionsFilter)
            }
            .eraseToAnyPublisher()
    }
    
    private func fetchAnswers(endpoint: Endpoint) -> AnyPublisher<[AnswersSummary], Never> {
        return serviceManager.fetch(endpoint: endpoint, model: Answers.self)
            .map { [weak self] answers -> AnyPublisher<(Answers, Comments), Error> in
                guard let self = self else { return Just((.empty, .empty)).setFailureType(to: Error.self).eraseToAnyPublisher() }
                
                let ids = answers.items.map(\.answerId).joinedString()
                let commentsPublisher = self.serviceManager.fetch(endpoint: .comments(subendpoint: .commentsByQuestionsIds(ids)), model: Comments.self)
                let answersPublisher = Just(answers).setFailureType(to: Error.self).eraseToAnyPublisher()
                
                return Publishers.CombineLatest(answersPublisher, commentsPublisher).eraseToAnyPublisher()
            }
            .switchToLatest()
            .map { (answers, comments) -> [AnswersSummary] in
                return answers.items.map { answer in
                    let comments = comments.items.filter { $0.postId == answer.answerId }.map(CommentsSummary.init)
                    return AnswersSummary(from: answer, comments: comments)
                }
            }
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
    
    private func fetchInbox() {
        guard let token = authenticationManager.stackConfig.token else {
            return
        }
        
        serviceManager.fetch(endpoint: .inbox(token: token, key: authenticationManager.stackConfig.key), model: Inbox.self)
            .map { [weak self] inbox -> AnyPublisher<[UserMessageSummary], Error> in
                guard let self = self else { return Just([]).setFailureType(to: Error.self).eraseToAnyPublisher() }
                
                let posts = inbox.items.map(MessageStatus.init)
                let answersIds = posts.filter { $0.messageType == .answer }.compactMap(\.id).joinedString()
                let commentsIds = posts.filter { $0.messageType == .comment }.compactMap(\.id).joinedString()
                
                return self.inboxPublisher(answersIds: answersIds, commentsIds: commentsIds)
                    .map { answer, comment -> [UserMessageSummary] in
                        let userAnswersSummary = answer.reduce([UserMessageSummary]()) { summary, answer in
                            let answerStatus = posts.filter { $0.messageType == .answer }.first(where: { $0.id == answer.answerId })!
                            var arr = summary
                            arr.append(UserMessageSummary(answer: answer, messageStatus: answerStatus))
                            return arr
                        }
                        
                        let userCommentsSummary = comment.reduce([UserMessageSummary]()) { summary, comment in
                            let commentStatus = posts.filter { $0.messageType == .comment }.first(where: { $0.id == comment.commentId })!
                            var arr = summary
                            arr.append(UserMessageSummary(comment: comment, messageStatus: commentStatus))
                            return arr
                        }
                        
                        return userAnswersSummary + userCommentsSummary
                    }.eraseToAnyPublisher()
            }
            .switchToLatest()
            .replaceError(with: [])
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.loadingSections.remove(.inbox)
            })
            .assign(to: \.inbox, on: self)
            .store(in: &subscriptions)
    }
    
    private func inboxPublisher(answersIds: String, commentsIds: String) -> AnyPublisher<([Answer], [Comment]), Error> {
        let answersPublisher = serviceManager.fetch(endpoint: .answers(subendpoint: .answersByIds(answersIds)),
                                                    model: Answers.self).map(\.items)
        let commentsPublisher = serviceManager.fetch(endpoint: .comments(subendpoint: .commentsByIds(commentsIds)),
                                                     model: Comments.self).map(\.items)
        
        return Publishers.Zip(answersPublisher, commentsPublisher).eraseToAnyPublisher()
    }
}

// MARK: - Webservice helpers
extension ViewManager {
    private func resolveQuestionsEndpointCall(from output: AppSection) -> AnyPublisher<[QuestionsSummary], Never> {
        switch output {
        case .questions(let subsection, let status):
            switch subsection {
            case .search(let keywords):
                return serviceManager.fetch(endpoint: .questions(subendpoint: .questionsByKeywords(keywords, status: status)),
                                            model: Search.self)
                    .map { $0.items.map(\.questionId).joinedString() }
                    .map { [weak self] ids -> AnyPublisher<[QuestionsSummary], Never> in
                        guard let self = self else { return Just([]).eraseToAnyPublisher() }
                        return self.fetchQuestions(endpoint: .questions(subendpoint: .questionsByIds(ids)))
                    }
                    .switchToLatest()
                    .replaceError(with: [])
                    .eraseToAnyPublisher()
            default:
                return fetchQuestions(endpoint: self.resolveEndpointType(from: output))
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
                return .questions(subendpoint: .questionsByFilters(tags: [], trending: trending, status: status))
            case .tag:
                return .questions(subendpoint: .questionsByFilters(tags: tags.filter(\.isFavorite), trending: .votes, status: status))
            case let .search(keywords):
                return .questions(subendpoint: .questionsByKeywords(keywords, status: status))
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
