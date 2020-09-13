//
//  UserSummary.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-08-09.
//

import Foundation
import struct SwiftUI.Color


enum BadgeType: Hashable {
    case bronze(value: Int)
    case silver(value: Int)
    case gold(value: Int)
    
    var color: Color {
        switch self {
        case .bronze:
            return Color("StackITBronze")
        case .gold:
            return Color("StackITGold")
        case .silver:
            return Color("StackITSilver")
        }
    }
    
    var value: String {
        switch self {
        case .bronze(let value), .gold(let value), .silver(let value):
            return value.string()
        }
    }
}

struct UserSummary {
    let accountId: Int
    let isEmployee: Bool
    let reputationChangeMonth, reputationChangeWeek, reputationChangeDay, reputation: Int
    let location: String
    let link, profileImage: String
    let displayName: String
    private let bronze, silver, gold: Int
    
    var badges: [BadgeType] {
        return [.bronze(value: bronze), .silver(value: silver), .gold(value: gold)]
    }
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
