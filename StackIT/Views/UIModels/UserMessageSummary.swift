//
//  UserMessageSummary.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-08-09.
//

import Foundation
import StackAPI

struct UserMessageSummary: Identifiable {
    let id = UUID()
    let title: String
    var messageDetails: [MessageDetail]
    let creationDate: String
    let isUnread: Bool
    let messageType: String
    let url: URL
    let body: String
    let authorName: String
    let profileImage: String
}

extension UserMessageSummary {
    init(answer: Answer, messageStatus: MessageStatus) {
        self.messageDetails = []
        self.body = answer.body
        self.creationDate = messageStatus.creationDate
        self.isUnread = messageStatus.isUnread
        self.messageType = messageStatus.messageType == .comment ? "Comment": "Answer"
        self.title = messageStatus.title
        self.url = URL(string: messageStatus.link)!
        self.authorName = answer.owner.displayName.unwrapped()
        self.profileImage = answer.owner.profileImage.unwrapped()
    }
    
    init(comment: Comment, messageStatus: MessageStatus) {
        self.messageDetails = []
        self.body = comment.body
        self.creationDate = messageStatus.creationDate
        self.isUnread = messageStatus.isUnread
        self.messageType = messageStatus.messageType == .comment ? "Comment": "Answer"
        self.title = messageStatus.title
        self.url = URL(string: messageStatus.link)!
        self.authorName = comment.owner.displayName.unwrapped()
        self.profileImage = comment.owner.profileImage.unwrapped()
    }
}
