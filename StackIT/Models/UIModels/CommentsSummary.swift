//
//  CommentsSummary.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-08-08.
//

import Foundation

struct CommentsSummary: Identifiable {
    var id = UUID()
    var body: String
    var authorName: String
    var authorReputation: String
    var authorImage: String
}

extension CommentsSummary {
    init(from comment: Comment) {
        self.body = comment.body.addStyling()
        self.authorName = comment.owner.displayName.unwrapped()
        self.authorReputation = comment.owner.reputation.string()
        self.authorImage = comment.owner.profileImage.unwrapped()
    }
}

extension CommentsSummary {
    static let placeholders: [CommentsSummary] = Array(0...13).map { _ in
        return CommentsSummary(body: "This is a placeholder comment",
                               authorName: "John Doe",
                               authorReputation: "4738",
                               authorImage: "")
    }
}
