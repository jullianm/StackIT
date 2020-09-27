//
//  QuestionsSummary.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-08-04.
//

import Foundation
import StackAPI

class QuestionsSummary: Identifiable, Equatable {
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
    var authorName: String
    var authorReputation: String
    var authorImage: String
    var comments: [CommentsSummary]
    var isSelected = false
    var isNoResultFound: Bool {
        return title.isEmpty && body.isEmpty
    }
    
    init(questionId: String, body: String, lastActivityDate: String, title: String, tags: [String], score: String, views: String, answers: String, hasAcceptedAnswer: Bool, isAnswered: Bool, authorName: String, authorReputation: String, authorImage: String, comments: [CommentsSummary], isClosed: Bool) {
        self.questionId = questionId
        self.body = body
        self.lastActivityDate = lastActivityDate
        self.title = title
        self.tags = tags
        self.score = score
        self.views = views
        self.answers = answers
        self.hasAcceptedAnswer = hasAcceptedAnswer
        self.isAnswered = isAnswered
        self.authorName = authorName
        self.authorReputation = authorReputation
        self.authorImage = authorImage
        self.comments = comments
        self.isClosed = isClosed
    }
    
    func setSelected(_ isSelected: Bool) {
        self.isSelected = isSelected
    }
    
    static func == (lhs: QuestionsSummary, rhs: QuestionsSummary) -> Bool {
        return lhs.id == rhs.id
    }
}

extension QuestionsSummary {
    convenience init(from question: Question, comments: [CommentsSummary]) {
        self.init(questionId: question.questionId.string(),
                  body: question.body.addStyling(),
                  lastActivityDate: "Last activity on \(question.lastActivityDate.stringDate())",
                  title: question.title,
                  tags: question.tags,
                  score: question.score.string(),
                  views: question.viewCount.formatNumber(),
                  answers: question.answerCount.string(),
                  hasAcceptedAnswer: (question.acceptedAnswerId != nil),
                  isAnswered: question.isAnswered,
                  authorName: question.owner.displayName.unwrapped(),
                  authorReputation: question.owner.reputation.string(),
                  authorImage: question.owner.profileImage.unwrapped(),
                  comments: comments,
                  isClosed: (question.closedDate != nil))
    }
}

extension QuestionsSummary {
    static let placeholders: [QuestionsSummary] = Array(0...13).map { _ in
        return QuestionsSummary(from: Question.placeholder, comments: [])
    }
    
    static let empty = [QuestionsSummary(questionId: "", body: "", lastActivityDate: "", title: "", tags: [], score: "", views: "", answers: "", hasAcceptedAnswer: true, isAnswered: true, authorName: "", authorReputation: "", authorImage: "", comments: [], isClosed: true)]
}
