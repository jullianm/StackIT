//
//  Search.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-08-06.
//

import Foundation

struct Search: Codable {
    let items: [SearchItem]
    let hasMore: Bool
}

// MARK: - Item
struct SearchItem: Codable {
    let tags: [String]
    let questionScore: Int
    let isAccepted: Bool
    let answerId: Int?
    let isAnswered: Bool
    let questionId: Int
    let itemType: ItemType
    let score, lastActivityDate, creationDate: Int
    let body, excerpt, title: String
    let hasAcceptedAnswer: Bool?
    let answerCount: Int?
}

enum ItemType: String, Codable {
    case answer = "answer"
    case question = "question"
}
