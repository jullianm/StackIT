//
//  Inbox.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-08-09.
//

import Foundation

struct Inbox: Codable {
    let items: [Message]
    let hasMore: Bool
    let quotaMax, quotaRemaining: Int
}

// MARK: - Item
struct Message: Codable {
    let isUnread: Bool
    let creationDate: Int
    let commentId, answerId: Int?
    let itemType: MessageType
    let link: String
    let title: String
    var body: String
}

enum MessageType: String, Codable {
    case comment = "comment"
    case answer = "new_answer"
}
