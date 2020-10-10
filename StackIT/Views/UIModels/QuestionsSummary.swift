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
    var questionId: String
    var body: [MessageDetail]
    var lastActivityDate: String
    var title: String
    var tags: [String]
    var score: String
    var views: String
    var answers: String
    var hasAcceptedAnswer: Bool
    var isAnswered: Bool
    var isClosed: Bool
    var commentCount: Int
    var authorName: String
    var authorReputation: String
    var authorImage: String
    var isSelected = false
    var isFavorite = false
    
    init(questionId: String,
         body: [MessageDetail],
         lastActivityDate: String,
         title: String,
         tags: [String],
         score: String,
         views: String,
         answers: String,
         hasAcceptedAnswer: Bool,
         isAnswered: Bool,
         isClosed: Bool,
         commentCount: Int,
         authorName: String,
         authorReputation: String,
         authorImage: String) {
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
        self.isClosed = isClosed
        self.commentCount = commentCount
        self.authorName = authorName
        self.authorReputation = authorReputation
        self.authorImage = authorImage
    }
    
    static func == (lhs: QuestionsSummary, rhs: QuestionsSummary) -> Bool {
        return lhs.id == rhs.id
    }
    
    var isNoResultFound: Bool {
        return title.isEmpty && body.isEmpty
    }
}

extension QuestionsSummary {
    convenience init(from question: Question) {
        self.init(questionId:question.questionId.string(),
                  body: MessageExtractor.sharedInstance.parse(html: question.body),
                  lastActivityDate: "Last activity on \(question.lastActivityDate.stringDate())",
                  title: question.title,
                  tags: question.tags,
                  score: question.score.string(),
                  views: question.viewCount.formatNumber(),
                  answers: question.answerCount.string(),
                  hasAcceptedAnswer: (question.acceptedAnswerId != nil),
                  isAnswered: question.isAnswered,
                  isClosed: (question.closedDate != nil),
                  commentCount: question.commentCount,
                  authorName: question.owner.displayName.unwrapped(),
                  authorReputation: question.owner.reputation.string(),
                  authorImage: question.owner.profileImage.unwrapped())
    }
}

extension QuestionsSummary {
    static let placeholders: [QuestionsSummary] = Array(0...13).map { _ in
        return QuestionsSummary(from: Question.placeholder)
    }
    
    static let empty = [QuestionsSummary(questionId: "",
                                         body: [],
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
