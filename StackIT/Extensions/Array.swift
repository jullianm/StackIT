//
//  Array.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-08-10.
//

import Foundation

extension Array where Element == QuestionsSummary {
    func filtered(by questionsFilter: Set<QuestionsFilter> ) -> Self {
        return questionsFilter.isEmpty ? self: filter {
            $0.hasAcceptedAnswer == questionsFilter.contains(.accepted) &&
                $0.isClosed == questionsFilter.contains(.closed) &&
                $0.isAnswered == !questionsFilter.contains(.unanswered)
        }.sorted(by: { lhs, rhs  in
            return lhs.score > rhs.score
        })
    }
}

extension Array where Element == String {
    func toData() -> Data {
        return (try? JSONEncoder().encode(self)) ?? .init()
    }
}

extension Array where Element == Int {
    func joinedString() -> String {
        return map { $0.string() }.joined(separator: ";")
    }
}
