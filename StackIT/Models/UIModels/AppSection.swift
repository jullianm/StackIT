//
//  AppSection.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-07-25.
//

import Foundation

enum AppSection: Equatable {
    case questions(subsection: SubSection)
    case answers(question: QuestionsSummary)
    case account(subsection: AccountSection)
    case authentication(action: AuthenticationAction)
}

enum SubSection: Equatable {
    case trending(trending: Trending)
    case tag(tag: Tag)
    case search(keywords: String)
}

extension AppSection {
    static let empty = (AppSection.questions(subsection: .tag(tag: .init(name: .init()))), false)
}

enum Trending: String, CaseIterable {
    case activity
    case votes
    case hot
    
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

enum AccountSection: CaseIterable {
    case profile
    case messages
    case activity
    
    var title: String {
        switch self {
        case .profile:
            return "Profile"
        case .messages:
            return "Inbox"
        case .activity:
            return "Historic"
        }
    }
}

enum QuestionsFilter: String, CaseIterable {
    case unanswered
    case closed
    case accepted
}

enum LoadingSection {
    case tags
    case questions
    case answers
    case account
}

class Tag: Comparable {
    let id = UUID()
    let name: String
    var isFavorite: Bool
    
    init(name: String, isFavorite: Bool = false) {
        self.name = name
        self.isFavorite = isFavorite
    }
    
    static func < (lhs: Tag, rhs: Tag) -> Bool {
        return lhs.name < rhs.name
    }
    
    static func == (lhs: Tag, rhs: Tag) -> Bool {
        return lhs.name == rhs.name
    }
}

extension Tag {
    static let popular: [Tag] = [
        Tag(name: "javascript"),
        Tag(name: "java"),
        Tag(name: "python"),
        Tag(name: "c#"),
        Tag(name: "php"),
        Tag(name: "android"),
        Tag(name: "html"),
        Tag(name: "jquery"),
        Tag(name: "c++"),
        Tag(name: "css"),
        Tag(name: "ios"),
        Tag(name: "mysql"),
        Tag(name: "sql"),
        Tag(name: "r"),
        Tag(name: "asp.net"),
        Tag(name: "node.js"),
        Tag(name: "arrays"),
        Tag(name: "c"),
        Tag(name: "ruby-on-rails"),
        Tag(name: ".net"),
        Tag(name: "json"),
        Tag(name: "objective-c"),
        Tag(name: "sql-server"),
        Tag(name: "swift"),
        Tag(name: "angularjs"),
        Tag(name: "python-3.x"),
        Tag(name: "django"),
        Tag(name: "reactjs"),
        Tag(name: "excel"),
        Tag(name: "regex")
    ]
}

enum AuthenticationAction: Equatable {
    case checkAuthentication
    case signIn(url: URL)
    case logOut
}
