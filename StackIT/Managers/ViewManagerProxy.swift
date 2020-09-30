//
//  NetworkManagerProxy.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-09-17.
//

import Combine
import StackAPI

typealias OutputQuestionsEvent = ((Questions) -> Void)?
typealias OutputSearchEvent = ((Search) -> Void)?

/// This class acts as a middle man between the different view managers and the `StackITAPI`
/// It should be used to trigger API calls.
class ViewManagerProxy {
    let api: StackITAPI
    var stackConfig: StackConfig?
    private var questionsFilter: Set<QuestionsFilter> = []
    
    init(api: StackITAPI) {
        self.api = api
    }
    
    func updateFilters(_ filters: Set<QuestionsFilter>) {
        questionsFilter = filters
    }
}

// MARK: - Tags API requests
extension ViewManagerProxy {
    func fetchTags() -> AnyPublisher<[TagSummary], Never> {
        return api.fetchPopularTags()
            .map { $0.items.map(\.name).map { TagSummary(name: $0) } }
            .replaceError(with: TagSummary.popular)
            .eraseToAnyPublisher()
    }
}

// MARK: - Questions API requests
extension ViewManagerProxy {
    func fetchQuestionsByKeywords(keywords: String,
                                  action: Action?,
                                  outputEvent: OutputSearchEvent) -> AnyPublisher<[QuestionsSummary], Never> {
        return api.fetchQuestionsByKeywords(keywords: keywords, action: action)
            .handleEvents(receiveOutput: outputEvent)
            .map { $0.items.map(\.questionId).joinedString() }
            .map { [weak self] ids -> AnyPublisher<[QuestionsSummary], Never> in
                guard let self = self else { return Just([]).eraseToAnyPublisher() }
                
                return self.api.fetchQuestionsByIds(ids)
                    .map { $0.items.map(QuestionsSummary.init) }
                    .replaceError(with: [])
                    .map { [self] in $0.filtered(by: self.questionsFilter) }
                    .eraseToAnyPublisher()
            }
            .switchToLatest()
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
    
    func fetchQuestionsWithFilters(tags: [String],
                                   trending: Trending,
                                   action: Action?,
                                   outputEvent: OutputQuestionsEvent) -> AnyPublisher<[QuestionsSummary], Never> {
        api.fetchQuestionsWithFilters(tags: tags, trending: trending, action: action)
            .handleEvents(receiveOutput: outputEvent)
            .map { $0.items.map(QuestionsSummary.init) }
            .replaceError(with: [])
            .map { [self] in $0.filtered(by: questionsFilter) }
            .eraseToAnyPublisher()
    }
    
    private func fetchQuestionsByIds(_ ids: String) -> AnyPublisher<[QuestionsSummary], Never> {
        api.fetchQuestionsByIds(ids)
            .map { $0.items.map(QuestionsSummary.init) }
            .replaceError(with: [])
            .map { [self] in $0.filtered(by: questionsFilter) }
            .eraseToAnyPublisher()
    }
}

// MARK: Answers API calls
extension ViewManagerProxy {
    private func fetchAnswersByIds(_ ids: String) -> AnyPublisher<[AnswersSummary], Never> {
        api.fetchAnswersByIds(ids)
            .map { $0.items.map(AnswersSummary.init) }
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
    
    func fetchAnswersByQuestionId(_ questionId: String) -> AnyPublisher<[AnswersSummary], Never> {
        api.fetchAnswersByQuestionId(questionId)
            .map { $0.items.map(AnswersSummary.init) }
            .replaceError(with: [])
            .eraseToAnyPublisher()
        
    }
}

// MARK: Comments API calls
extension ViewManagerProxy {
    func fetchCommentsByAnswerId(_ answerId: String) -> AnyPublisher<[CommentsSummary], Never> {
        api.fetchCommentsByAnswersIds(answerId)
            .map { $0.items.map(CommentsSummary.init) }
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
    
    func fetchCommentsByQuestionId(_ questionId: String) -> AnyPublisher<[CommentsSummary], Never> {
        api.fetchCommentsByQuestionsIds(questionId)
            .map { $0.items.map(CommentsSummary.init) }
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
}

// MARK: User API calls
extension ViewManagerProxy {
    func fetchInbox() -> AnyPublisher<[UserMessageSummary], Never> {
        guard let token = stackConfig?.token, let key = stackConfig?.key else {
            return Just([]).eraseToAnyPublisher()
        }
        
        return api.fetchInbox(token: token, key: key)
            .map { [weak self] inbox -> AnyPublisher<[UserMessageSummary], Error> in
                guard let self = self else {
                    return Just([])
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                
                let posts = inbox.items.map(MessageStatus.init)
                let answersIds = posts.filter { $0.messageType == .answer }.compactMap(\.id).joinedString()
                let commentsIds = posts.filter { $0.messageType == .comment }.compactMap(\.id).joinedString()
                
                let answersPublisher = self.api.fetchAnswersByIds(answersIds).map(\.items)
                let commentsPublisher = self.api.fetchCommentsByIds(commentsIds).map(\.items)
                
                let zip = Publishers.Zip(answersPublisher, commentsPublisher).eraseToAnyPublisher()
                
                return zip
                    .map { answer, comment -> [UserMessageSummary] in
                        let userAnswersSummary = answer.reduce([UserMessageSummary]()) { summary, answer in
                            let answerStatus = posts.filter { $0.messageType == .answer }.first(where: { $0.id == answer.answerId })!
                            var arr = summary
                            arr.append(UserMessageSummary(answer: answer, messageStatus: answerStatus))
                            return arr
                        }
                        
                        let userCommentsSummary = comment.reduce([UserMessageSummary]()) { summary, comment in
                            let commentStatus = posts.filter {
                                $0.messageType == .comment }.first(where: { $0.id == comment.commentId })!
                            var arr = summary
                            arr.append(UserMessageSummary(comment: comment, messageStatus: commentStatus))
                            return arr
                        }
                        
                        return userAnswersSummary + userCommentsSummary
                    }.eraseToAnyPublisher()
            }
            .switchToLatest()
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
    
    func fetchTimeline() -> AnyPublisher<[TimelineSummary], Never> {
        guard let token = stackConfig?.token, let key = stackConfig?.key else {
            return Just([]).eraseToAnyPublisher()
        }
        
        return api.fetchTimeline(token: token, key: key)
            .map { $0.items.map(TimelineSummary.init) }
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
}
