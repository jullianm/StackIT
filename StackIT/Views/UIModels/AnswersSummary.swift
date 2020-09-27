//
//  AnswersSummary.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-08-04.
//

import Foundation
import StackAPI

struct AnswersSummary: Identifiable {
    var id = UUID()
    var lastActivityDate: String
    var score: String
    var isAccepted: Bool
    var body: String
    var authorName: String
    var authorReputation: String
    var authorImage: String
    var comments: [CommentsSummary]
}

extension AnswersSummary {
    init(from answer: Answer, comments: [CommentsSummary]) {
        self.lastActivityDate = "Last activity on \(answer.lastActivityDate.stringDate())"
        self.score = answer.score.string()
        self.body = answer.body.addStyling()
        self.isAccepted = answer.isAccepted
        self.authorName = answer.owner.displayName.unwrapped()
        self.authorReputation = answer.owner.reputation.string()
        self.authorImage = answer.owner.profileImage.unwrapped()
        self.comments = comments
    }
    
    init(from answer: Answer) {
        self.lastActivityDate = "Last activity on \(answer.lastActivityDate.stringDate())"
        self.score = answer.score.string()
        self.body = answer.body.addStyling()
        self.isAccepted = answer.isAccepted
        self.authorName = answer.owner.displayName.unwrapped()
        self.authorReputation = answer.owner.reputation.string()
        self.authorImage = answer.owner.profileImage.unwrapped()
        self.comments = []
    }
}

extension AnswersSummary {
    static let placeholders = Array(0...10).map { _ in
        return AnswersSummary(from: Answer.placeholder, comments: CommentsSummary.placeholders)
    }
}
