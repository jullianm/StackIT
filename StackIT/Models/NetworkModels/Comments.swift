//
//  Comments.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-08-08.
//

import Foundation

// MARK: - Welcome
struct Comments: Codable {
    let items: [Comment]
    let hasMore: Bool
    let quotaRemaining: Int
}

extension Comments {
    static let empty = Comments(items: [], hasMore: false, quotaRemaining: 0)
}

// MARK: - Item
struct Comment: Codable {
    let owner: Owner
    let edited: Bool
    let score, creationDate, postId, commentId: Int
    let body: String
    let replyToUser: Owner?
}
