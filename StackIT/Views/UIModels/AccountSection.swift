//
//  AccountSection.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-09-26.
//

import Foundation

enum AccountSection: CaseIterable, Identifiable {
    case profile
    case messages
    case timeline
    
    var id: UUID {
        UUID()
    }
    
    var title: String {
        switch self {
        case .profile:
            return "Profile"
        case .messages:
            return "Inbox"
        case .timeline:
            return "Timeline"
        }
    }
}
