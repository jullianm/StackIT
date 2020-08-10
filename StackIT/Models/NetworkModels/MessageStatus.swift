//
//  MessageStatus.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-08-09.
//

import Foundation

struct MessageStatus {
    let id: Int?
    let creationDate: String
    let link: String
    let title: String
    let isUnread: Bool
    let messageType: MessageType
}

extension MessageStatus {
    init(from message: Message) {
        self.title = message.title
        self.creationDate = message.creationDate.stringDate()
        self.link = message.link
        self.id = (message.itemType == .answer) ? message.answerId: message.commentId
        self.isUnread = message.isUnread
        self.messageType = message.itemType
    }
}
