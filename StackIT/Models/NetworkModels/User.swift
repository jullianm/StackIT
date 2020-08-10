//
//  User.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-08-08.
//

import Foundation

// MARK: - Welcome
struct User: Codable {
    let items: [UserDetails]
}

struct UserDetails: Codable {
    let badgeCounts: BadgeCounts
    let accountId: Int
    let isEmployee: Bool
    let lastModifiedDate, lastAccessDate, reputationChangeYear, reputationChangeQuarter: Int
    let reputationChangeMonth, reputationChangeWeek, reputationChangeDay, reputation: Int
    let creationDate: Int
    let userType: String
    let userId: Int
    let location: String
    let link, profileImage: String
    let displayName: String
}

struct BadgeCounts: Codable {
    let bronze, silver, gold: Int
}

extension User {
    static let empty = User(items: [])
}
