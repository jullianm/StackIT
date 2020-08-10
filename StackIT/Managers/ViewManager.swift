//
//  ViewModel.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-07-25.
//

import Combine
import Foundation

typealias SectionOutput = (section: AppSection, isPagingEnabled: Bool)

class ViewManager: ObservableObject {
    /// Published properties
    @Published var tags: [Tag] = Tag.popular
    @Published var questionsSummary: [QuestionsSummary] = QuestionsSummary.placeholders
    @Published var questionsFilter: Set<QuestionsFilter> = []
    @Published var answersSummary: [AnswersSummary] = []
    @Published var loadingSections: Set<LoadingSection> = []
    @Published var showLoadMore: Bool = false
    @Published var isAuthenticated: Bool = false
    @Published var user: UserSummary?
    @Published var inbox: [UserMessageSummary] = []

    /// Private properties
    private var serviceManager: ServiceManager
    private var authenticationManager: AuthenticationManager
    private var subscriptions = Set<AnyCancellable>()
    
    /// Public properties
    var cachedQuestions: [QuestionsSummary] = []

    /// Subjects properties
    var fetchQuestionsSubject = CurrentValueSubject<SectionOutput, Never>(AppSection.empty)
    var fetchAnswersSubject = CurrentValueSubject<SectionOutput, Never>(AppSection.empty)
    var fetchAccountSectionSubject = PassthroughSubject<AccountSection, Never>()
    var authenticationSubject = CurrentValueSubject<AuthenticationAction, Never>(.checkAuthentication)
    
    init(serviceManager: ServiceManager = NetworkManager(), authenticationManager: AuthenticationManager = .shared) {
        #if DEBUG
        self.serviceManager = MockManager()
        #else
        self.serviceManager = serviceManager
        #endif
        self.authenticationManager = authenticationManager
        fetchData()
        setupBindings()
    }
    
    private func setupBindings() {
        bindFetchQuestions()
        bindFetchAnswers()
        bindAuthentication()
        bindFetchAccount()
    }
    
    func updateQuestionsFilter(_ filter: QuestionsFilter) {
        if questionsFilter.contains(filter) {
            questionsFilter.remove(filter)
        } else {
            questionsFilter.insert(filter)
        }

        questionsSummary = questionsFilter.isEmpty ?
            cachedQuestions:
            cachedQuestions.filtered(by: questionsFilter)
    }
}

// MARK: - Posts-related bindings
extension ViewManager {
    private func bindFetchQuestions() {
        fetchQuestionsSubject
            .dropFirst()
            .handleEvents(receiveOutput: handleOutputSectionEvent)
            .map(resolveEndpointCall)
            .switchToLatest()
            .handleEvents(receiveOutput: { _ in self.loadingSections = [] })
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
            .handleEvents(receiveOutput: { _ in self.loadingSections = [] })
            .replaceError(with: [])
            .assign(to: \.answersSummary, on: self)
            .store(in: &subscriptions)
    }
}

// MARK: - Account-related bindings
extension ViewManager {
    private func bindFetchAccount() {
        fetchAccountSectionSubject
            .sink { [self] section in
                switch section {
                case .messages:
                    fetchInbox()
                case .activity:
                    break /// ⚠️  To do.
                case .profile:
                    return /// ⚠️ We already have current user informations in `User` object.
                }
            }.store(in: &subscriptions)
    }
    
    private func bindAuthentication() {
        authenticationSubject
            .handleEvents(receiveOutput: { [self] action in
                switch action {
                case .checkAuthentication:
                    authenticationManager.checkTokenSubject.send(())
                case .signIn(let url):
                    authenticationManager.parseTokenSubject.send(url)
                case .logOut:
                    authenticationManager.removeUserSubject.send(())
                }
                
                loadingSections = [.account]
            })
            .map { [self] _ in authenticationManager.addUserSubject }
            .switchToLatest()
            .sink { user in
                self.user = user
                self.loadingSections = []
            }.store(in: &subscriptions)
    }
}

// MARK: - Webservices call
extension ViewManager {
    private func fetchData() {
        let tagsPublisher = fetchTags()
        let questionsPublisher = fetchQuestions(endpoint: .filteredQuestions(tags: [], trending: .votes, page: 1))
        
        Publishers.CombineLatest(tagsPublisher, questionsPublisher)
            .handleEvents(receiveSubscription: { _ in
                self.loadingSections = [.tags, .questions]
            }, receiveOutput: { _ in
                self.loadingSections = []
            })
            .sink(receiveValue: { tags, questions in
                self.tags = tags
                self.questionsSummary = questions
            }).store(in: &subscriptions)
    }
    
    private func fetchTags() -> AnyPublisher<[Tag], Never> {
        return serviceManager.fetch(endpoint: .tags, model: Tags.self)
            .map { $0.items.map(\.name).map { Tag(name: $0) } }
            .replaceError(with: Tag.popular)
            .eraseToAnyPublisher()
    }
    
    private func fetchQuestions(endpoint: Endpoint) -> AnyPublisher<[QuestionsSummary], Never> {
        return serviceManager.fetch(endpoint: endpoint, model: Questions.self)
            .handleEvents(receiveOutput: { [self] questions in
                showLoadMore = questions.hasMore && questions.quotaRemaining > 0
            })
            .map { $0.items.map(QuestionsSummary.init) }
            .replaceError(with: [])
            .map { $0.filtered(by: self.questionsFilter) }
            .eraseToAnyPublisher()
    }
    
    private func fetchAnswers(endpoint: Endpoint) -> AnyPublisher<[AnswersSummary], Never> {
        return serviceManager.fetch(endpoint: endpoint, model: Answers.self)
            .map { answers -> AnyPublisher<(Answers, Comments), Error> in
                let ids = answers.items.map(\.answerId).joinedString()
                let commentsPublisher = self.serviceManager.fetch(endpoint: .commentsForAnswers(answersId: ids), model: Comments.self)
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
            .map { [self] inbox -> AnyPublisher<[UserMessageSummary], Error> in
                let posts = inbox.items.map(MessageStatus.init)
                let answersIds = posts.filter { $0.messageType == .answer }.compactMap(\.id).joinedString()
                let commentsIds = posts.filter { $0.messageType == .comment }.compactMap(\.id).joinedString()
                
                return inboxPublisher(answersIds: answersIds, commentsIds: commentsIds)
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
            .assign(to: \.inbox, on: self)
            .store(in: &subscriptions)
    }
    
    private func inboxPublisher(answersIds: String, commentsIds: String) -> AnyPublisher<([Answer], [Comment]), Error> {
        let answersPublisher = serviceManager.fetch(endpoint: .answers(ids: answersIds), model: Answers.self).map(\.items)
        let commentsPublisher = serviceManager.fetch(endpoint: .comments(ids: commentsIds), model: Comments.self).map(\.items)
        
        return Publishers.Zip(answersPublisher, commentsPublisher).eraseToAnyPublisher()
    }
}

// MARK: - Webservice helpers
extension ViewManager {
    private func resolveEndpointCall(from output: SectionOutput) -> AnyPublisher<[QuestionsSummary], Never> {
        switch output.section {
        case .search(let keywords):
            return serviceManager.fetch(endpoint: .search(keywords: keywords), model: Search.self)
                .map { $0.items.map(\.questionId).joinedString() }
                .map { [self] in fetchQuestions(endpoint: .questions(ids: $0)) }
                .switchToLatest()
                .replaceError(with: [])
                .eraseToAnyPublisher()
        default:
            return fetchQuestions(endpoint: self.resolveEndpointType(from: output))
        }
    }
    
    private func resolveEndpointType(from output: SectionOutput) -> Endpoint {
        switch output.section {
        case let .trending(trending):
            return .filteredQuestions(tags: [], trending: trending, page: QuestionsSummary.currentPage)
        case .tag:
            return .filteredQuestions(tags: tags.filter(\.isFavorite), trending: .votes, page: QuestionsSummary.currentPage)
        case let .search(keywords):
            return .search(keywords: keywords)
        case let .answers(questionId):
            return .answersForQuestion(questionId: questionId)
        }
    }
    
    private func handleOutputSectionEvent(output: SectionOutput) {
        QuestionsSummary.updatePaging(isEnabled: output.isPagingEnabled)
        
        switch output.section {
        case .trending:
            loadingSections = [.questions]
        case .tag(let tag):
            if !output.isPagingEnabled { tags.first(where: { $0.name == tag.name })?.isFavorite.toggle() }
            loadingSections = [.questions]
        case .answers:
            loadingSections = [.answers]
        case .search:
            tags.forEach { $0.isFavorite = false }
            loadingSections = [.questions]
        }
    }
}
