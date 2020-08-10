//
//  UserSummary.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-08-09.
//

import Foundation

struct UserSummary {
    let accountId: Int
    let isEmployee: Bool
    let reputationChangeMonth, reputationChangeWeek, reputationChangeDay, reputation: Int
    let location: String
    let link, profileImage: String
    let displayName: String
    let bronze, silver, gold: Int
}

extension UserSummary {
    init(user: UserDetails) {
        self.accountId = user.accountId
        self.isEmployee = user.isEmployee
        self.reputationChangeMonth = user.reputationChangeMonth
        self.reputationChangeWeek = user.reputationChangeWeek
        self.reputationChangeDay = user.reputationChangeDay
        self.reputation = user.reputation
        self.location = user.location
        self.link = user.link
        self.displayName = user.displayName
        self.profileImage = user.profileImage
        self.bronze = user.badgeCounts.bronze
        self.silver = user.badgeCounts.silver
        self.gold = user.badgeCounts.gold
    }
}
