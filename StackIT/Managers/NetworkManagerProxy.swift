//
//  NetworkManagerProxy.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-09-17.
//

import Combine

/// This class acts as a middle man between the `ViewManager` and the `NetworkManager`
/// It should be used to trigger API calls.
class NetworkManagerProxy {
    let serviceManager: ServiceManager
    var stackConfig: StackConfig?
    
    init(serviceManager: ServiceManager) {
        self.serviceManager = serviceManager
    }
    
    func fetchTags() -> AnyPublisher<[Tag], Never> {
        return serviceManager.fetch(endpoint: .tags, model: Tags.self)
            .map { $0.items.map(\.name).map { Tag(name: $0) } }
            .replaceError(with: Tag.popular)
            .eraseToAnyPublisher()
    }
}

// MARK: - Answers API requests
extension NetworkManagerProxy {
    func fetchAnswers(endpoint: Endpoint) -> AnyPublisher<[AnswersSummary], Never> {
        return serviceManager.fetch(endpoint: endpoint, model: Answers.self)
            .map { [weak self] answers -> AnyPublisher<(Answers, Comments), Error> in
                guard let self = self else { return Just((.empty, .empty)).setFailureType(to: Error.self).eraseToAnyPublisher() }
                
                let ids = answers.items.map(\.answerId).joinedString()
                let commentsPublisher = self.serviceManager.fetch(endpoint: .comments(subendpoint: .commentsByAnswersIds(ids)), model: Comments.self)
                let answersPublisher = Just(answers).setFailureType(to: Error.self).eraseToAnyPublisher()
                
                return Publishers.CombineLatest(answersPublisher,
                                                commentsPublisher).eraseToAnyPublisher()
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
}

// MARK: - Questions API requests
extension NetworkManagerProxy {
    func fetchQuestions(endpoint: Endpoint,
                        filteredBy filters: Set<QuestionsFilter>,
                        onOutputReceived: ((Questions) -> Void)? = nil) -> AnyPublisher<[QuestionsSummary], Never> {
        return serviceManager.fetch(endpoint: endpoint, model: Questions.self)
            .handleEvents(receiveOutput: {
                onOutputReceived?($0)
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
            .map { $0.filtered(by: filters) }
            .eraseToAnyPublisher()
    }
    
    func fetchQuestionsByKeywords(keywords: String,
                                  status: SectionStatus,
                                  filteredBy filters: Set<QuestionsFilter>) -> AnyPublisher<[QuestionsSummary], Never> {
        return serviceManager.fetch(endpoint: .questions(subendpoint: .questionsByKeywords(keywords, status: status)), model: Search.self)
            .map { $0.items.map(\.questionId).joinedString() }
            .map { [weak self] ids -> AnyPublisher<[QuestionsSummary], Never> in
                guard let self = self else { return Just([]).eraseToAnyPublisher() }
                return self.fetchQuestions(endpoint: .questions(subendpoint: .questionsByIds(ids)),
                                           filteredBy: filters)
            }
            .switchToLatest()
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
}

// MARK: - Account API requests
extension NetworkManagerProxy {
    func fetchInbox() -> AnyPublisher<[UserMessageSummary], Never> {
        guard let token = stackConfig?.token, let key = stackConfig?.key else {
            return Just([]).eraseToAnyPublisher()
        }
        
        return serviceManager.fetch(endpoint: .inbox(token: token, key: key), model: Inbox.self)
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
            .eraseToAnyPublisher()
    }
    
    private func inboxPublisher(answersIds: String, commentsIds: String) -> AnyPublisher<([Answer], [Comment]), Error> {
        let answersPublisher = serviceManager.fetch(endpoint: .answers(subendpoint: .answersByIds(answersIds)),
                                                    model: Answers.self).map(\.items)
        let commentsPublisher = serviceManager.fetch(endpoint: .comments(subendpoint: .commentsByIds(commentsIds)),
                                                     model: Comments.self).map(\.items)
        
        return Publishers.Zip(answersPublisher, commentsPublisher).eraseToAnyPublisher()
    }
    
    func fetchTimeline() -> AnyPublisher<[TimelineSummary], Never> {
        guard let token = stackConfig?.token, let key = stackConfig?.key else {
            return Just([]).eraseToAnyPublisher()
        }
        
        return serviceManager.fetch(endpoint: .timeline(token: token, key: key), model: Timeline.self)
            .map { $0.items.map(TimelineSummary.init) }
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
}
