//
//  Trending.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-09-26.
//

import StackAPI

extension Trending {
    var title: String {
        switch self {
        case .activity:
            return "Recent"
        case .hot:
            return "Hot"
        case .votes:
            return "Score"
        }
    }
    
    var iconName: String {
        switch self {
        case .activity:
            return "calendar.circle.fill"
        case .hot:
            return "sun.max"
        case .votes:
            return "hand.thumbsup.fill"
        }
    }
}

