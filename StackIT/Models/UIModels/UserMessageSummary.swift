//
//  UserMessageSummary.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-08-09.
//

import Foundation

struct UserMessageSummary: Identifiable {
    let id = UUID()
    let title: String
    let body: String
    let creationDate: String
    let isUnread: Bool
    let messageType: String
    let url: URL
    let authorName: String
    let profileImage: String
}

extension UserMessageSummary {
    init(answer: Answer, messageStatus: MessageStatus) {
        self.body = answer.body.addStyling()
        self.creationDate = "Created on \(messageStatus)"
        self.isUnread = messageStatus.isUnread
        self.messageType = messageStatus.messageType == .comment ? "Comment": "Answer"
        self.title = messageStatus.title
        self.url = URL(string: messageStatus.link)!
        self.authorName = answer.owner.displayName.unwrapped()
        self.profileImage = answer.owner.profileImage.unwrapped()
    }
    
    init(comment: Comment, messageStatus: MessageStatus) {
        self.body = comment.body.addStyling()
        self.creationDate = "Created on \(messageStatus)"
        self.isUnread = messageStatus.isUnread
        self.messageType = messageStatus.messageType == .comment ? "Comment": "Answer"
        self.title = messageStatus.title
        self.url = URL(string: messageStatus.link)!
        self.authorName = comment.owner.displayName.unwrapped()
        self.profileImage = comment.owner.profileImage.unwrapped()
    }
}
