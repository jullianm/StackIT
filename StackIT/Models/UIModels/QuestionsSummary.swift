//
//  QuestionsSummary.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-08-04.
//

import Foundation

struct QuestionsSummary: Identifiable {
    var id = UUID()
    let questionId: String
    let body: String
    var lastActivityDate: String
    let title: String
    let tags: [String]
    let votes: String
    let views: String
    let answers: String
    let hasAcceptedAnswer: Bool
    let isAnswered: Bool
    let isClosed: Bool
}

extension QuestionsSummary {
    init(from question: Question) {
        self.questionId = question.questionId.string()
        self.body = question.body
        self.lastActivityDate = "Last activity on \(question.lastActivityDate.stringDate())"
        self.title = question.title
        self.tags = question.tags
        self.votes = question.score.string()
        self.views = question.viewCount.formatNumber()
        self.answers = question.answerCount.string()
        self.hasAcceptedAnswer = (question.acceptedAnswerId != nil)
        self.isAnswered = question.isAnswered
        self.isClosed = (question.closedDate != nil)
    }
    
    init(from search: SearchItem) {
        self.questionId = search.questionId.string()
        self.body = .init()
        self.lastActivityDate = "Last activity on \(search.lastActivityDate.stringDate())"
        self.title = search.title
        self.tags = search.tags
        self.votes = search.score.string()
        self.views = .init()
        self.answers = search.answerCount.string()
        self.hasAcceptedAnswer = (search.hasAcceptedAnswer != nil)
        self.isAnswered = search.isAnswered
        self.isClosed = false
    }
}

extension QuestionsSummary {
    static var isPagingEnabled = false
    static var currentPage = 1
    static let placeholders: [QuestionsSummary] = Array(0...13).map { _ in
        return QuestionsSummary(from: Question.placeholder)
    }
    
    static func updatePaging(isEnabled: Bool) {
        isPagingEnabled = isEnabled
        currentPage = isEnabled ? currentPage + 1: 1
    }
}
