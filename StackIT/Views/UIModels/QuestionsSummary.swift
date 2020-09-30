//
//  QuestionsSummary.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-08-04.
//

import Foundation
import StackAPI

struct QuestionsSummary: Identifiable, Equatable {
    var id = UUID()
    let questionId: String
    let body: String
    var lastActivityDate: String
    let title: String
    let tags: [String]
    let score: String
    let views: String
    let answers: String
    let hasAcceptedAnswer: Bool
    let isAnswered: Bool
    let isClosed: Bool
    let commentCount: Int
    var authorName: String
    var authorReputation: String
    var authorImage: String
    var isSelected = false
    var isNoResultFound: Bool {
        return title.isEmpty && body.isEmpty
    }

    mutating func setSelected(_ isSelected: Bool) {
        self.isSelected = isSelected
    }
    
    static func == (lhs: QuestionsSummary, rhs: QuestionsSummary) -> Bool {
        return lhs.id == rhs.id
    }
}

extension QuestionsSummary {
    init(from question: Question) {
        self.questionId = question.questionId.string()
        self.body = question.body.addStyling()
        self.lastActivityDate = "Last activity on \(question.lastActivityDate.stringDate())"
        self.title = question.title
        self.tags = question.tags
        self.score = question.score.string()
        self.views = question.viewCount.formatNumber()
        self.answers = question.answerCount.string()
        self.hasAcceptedAnswer = (question.acceptedAnswerId != nil)
        self.isAnswered = question.isAnswered
        self.authorName = question.owner.displayName.unwrapped()
        self.authorReputation = question.owner.reputation.string()
        self.authorImage = question.owner.profileImage.unwrapped()
        self.isClosed = (question.closedDate != nil)
        self.commentCount = question.commentCount
    }
}

extension QuestionsSummary {
    static let placeholders: [QuestionsSummary] = Array(0...13).map { _ in
        return QuestionsSummary(from: Question.placeholder)
    }
    
    static let empty = [QuestionsSummary(questionId: "",
                                         body: "",
                                         lastActivityDate: "",
                                         title: "",
                                         tags: [],
                                         score: "",
                                         views: "",
                                         answers: "",
                                         hasAcceptedAnswer: false,
                                         isAnswered: false,
                                         isClosed: false,
                                         commentCount: 5,
                                         authorName: "",
                                         authorReputation: "",
                                         authorImage: "")]
}
