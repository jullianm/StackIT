//
//  SOQuestions.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-07-25.
//

import Foundation

struct Questions: Codable {
    let items: [Question]
    let hasMore: Bool
    let quotaRemaining: Int
}

extension Questions {
    static let empty = Questions(items: [], hasMore: false, quotaRemaining: 0)
}

// MARK: - Item
struct Question: Codable {
    let tags: [String]
    let owner: Owner
    let isAnswered: Bool
    let viewCount, answerCount, score, lastActivityDate: Int
    let creationDate: Int
    let lastEditDate: Int?
    let questionId: Int
    let link: String
    let title: String
    let body: String
    let acceptedAnswerId, closedDate: Int?
    let closedReason: String?
}

struct Owner: Codable {
    let reputation: Int?
    let userId: Int?
    let userType: String?
    let profileImage: String?
    let displayName: String?
    let link: String?
    let acceptRate: Int?
}

extension Question {
    static let placeholder = Question(tags: ["swift", "android", "ios"],
                                      owner: Owner.placeholder,
                                      isAnswered: true,
                                      viewCount: 2000000,
                                      answerCount: 25,
                                      score: 3456,
                                      lastActivityDate: 1590047664,
                                      creationDate: 1590047664,
                                      lastEditDate: 1590047664,
                                      questionId: 3548,
                                      link: "",
                                      title: "How to handle SwiftUI navigation View?",
                                      body: "",
                                      acceptedAnswerId: nil,
                                      closedDate: 1590047664,
                                      closedReason: nil)
}

extension Owner {
    static let placeholder = Owner(reputation: 75896,
                                   userId: nil,
                                   userType: nil,
                                   profileImage: "https://www.gravatar.com/avatar/43ac0b36d98aa42d34d93ecc582a469c?s=128&d=identicon&r=PG",
                                   displayName: "Placeholder",
                                   link: nil,
                                   acceptRate: nil)
}
