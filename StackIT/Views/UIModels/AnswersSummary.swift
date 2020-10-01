//
//  AnswersSummary.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-08-04.
//

import Foundation
import StackAPI

struct AnswersSummary: Identifiable, Equatable {
    var id = UUID()
    var lastActivityDate: String
    var score: String
    var isAccepted: Bool
    var body: [MessageDetail]
    var authorName: String
    var authorReputation: String
    var authorImage: String
    var answerId: String
    var commentCount: String
}

extension AnswersSummary {
    
    init(from answer: Answer) {
        self.lastActivityDate = "Last activity on \(answer.lastActivityDate.stringDate())"
        self.score = answer.score.string()
        self.body = MessageExtractor.sharedInstance.parse(html: answer.body)
        self.isAccepted = answer.isAccepted
        self.authorName = answer.owner.displayName.unwrapped()
        self.authorReputation = answer.owner.reputation.string()
        self.authorImage = answer.owner.profileImage.unwrapped()
        self.answerId = answer.answerId.string()
        self.commentCount = answer.commentCount.string()
    }
}

extension AnswersSummary {
    static let placeholders = Array(0...10).map { _ in
        return AnswersSummary(from: Answer.placeholder)
    }
}
