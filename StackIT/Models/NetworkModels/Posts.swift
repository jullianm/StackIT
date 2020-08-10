//
//  Posts.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-08-09.
//

import Foundation

struct Posts: Codable {
    let items: [Post]
    let hasMore: Bool
    let quotaMax, quotaRemaining: Int
}

// MARK: - Item
struct Post: Codable {
    let owner: Owner
    let score, lastActivityDate, creationDate: Int
    let postType: String
    let postId: Int
    let contentLicense: String
    let link: String
    let lastEditDate: Int?
}
