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

/// This class acts as a middle man between the `ViewManager` and the `StackITAPI`
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
                
                return self.publishQuestionsSummary(
                    input: self.api.fetchQuestionsByIds(ids)
                )
            }
            .switchToLatest()
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
    
    func fetchQuestionsWithFilters(tags: [String],
                                   trending: Trending,
                                   action: Action?,
                                   outputEvent: OutputQuestionsEvent) -> AnyPublisher<[QuestionsSummary], Never> {
        return self.publishQuestionsSummary(
            input: api.fetchQuestionsWithFilters(tags: tags, trending: trending, action: action),
            outputEvent: outputEvent
        )
    }
    
    private func fetchQuestionsByIds(_ ids: String) -> AnyPublisher<[QuestionsSummary], Never> {
        return self.publishQuestionsSummary(
            input: api.fetchQuestionsByIds(ids)
        )
    }
}

// MARK: Answers API calls
extension ViewManagerProxy {
    private func fetchAnswersByIds(_ ids: String) -> AnyPublisher<[AnswersSummary], Never> {
        return publishAnswersSummary(
            input: self.api.fetchAnswersByIds(ids)
        )
    }

    func fetchAnswersByQuestionId(_ questionId: String) -> AnyPublisher<[AnswersSummary], Never> {
        return publishAnswersSummary(
            input: self.api.fetchAnswersByQuestionId(questionId)
        )
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


extension ViewManagerProxy {
    private func publishQuestionsSummary(input: AnyPublisher<Questions, Error>,
                                         outputEvent: OutputQuestionsEvent = nil) -> AnyPublisher<[QuestionsSummary], Never> {
        return input
            .handleEvents(receiveOutput: outputEvent)
            .map { [weak self] questions -> AnyPublisher<(Questions, Comments), Never> in
                guard let self = self else {
                    return Just((.empty, .empty)).eraseToAnyPublisher()
                }
                let ids = questions.items.map(\.questionId).joinedString()
                
                let commentsPublisher = self.api.fetchCommentsByQuestionsIds(ids)
                    .eraseToAnyPublisher()
                
                let questionsPublisher = Just(questions)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
                
                let combined = Publishers.CombineLatest(questionsPublisher,
                                                        commentsPublisher).eraseToAnyPublisher()
                
                return combined
                    .replaceError(with: (.empty, .empty))
                    .eraseToAnyPublisher()
            }
            .switchToLatest()
            .map { (questions, comments) -> [QuestionsSummary] in
                return questions.items.map { question in
                    
                    let comments = comments.items.filter {
                        $0.postId == question.questionId
                    }.map(CommentsSummary.init)
                    
                    return QuestionsSummary(from: question, comments: comments)
                }
            }
            .replaceError(with: [])
            .map { [self] in $0.filtered(by: questionsFilter) }
            .eraseToAnyPublisher()
    }
    
    private func publishAnswersSummary(input: AnyPublisher<Answers, Error>) -> AnyPublisher<[AnswersSummary], Never>  {
        return input
            .map { [weak self] answers -> AnyPublisher<(Answers, Comments), Error> in
                guard let self = self else {
                    return Just((.empty, .empty))
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                let ids = answers.items.map(\.answerId).joinedString()
                let commentsPublisher = self.api.fetchCommentsByAnswersIds(ids)
                let answersPublisher = Just(answers).setFailureType(to: Error.self).eraseToAnyPublisher()
                
                let combined = Publishers.CombineLatest(answersPublisher, commentsPublisher)
                
                return combined.eraseToAnyPublisher()
            }
            .switchToLatest()
            .map { (answers, comments) -> [AnswersSummary] in
                return answers.items.map { answer in
                    
                    let comments = comments.items.filter {
                        $0.postId == answer.answerId
                    }.map(CommentsSummary.init)
                    
                    return AnswersSummary(from: answer, comments: comments)
                }
            }
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
}
