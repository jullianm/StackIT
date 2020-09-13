//
//  Activity.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-09-13.
//

import Foundation

struct Timeline: Codable {
    let items: [TimelineItems]
    let hasMore: Bool
    let quotaMax, quotaRemaining: Int
}

struct TimelineItems: Codable {
    let postId, userId: Int?
    let timelineType: TimelineType
    let creationDate: Int
    let title: String?
    let detail: String?
    let commentId, badgeId: Int?

}

enum TimelineType: String, Codable {
    case acceptedAnAnswer = "accepted"
    case postedAnAnswer = "answered"
    case askedAQuestion = "asked"
    case earnedABadge = "badge"
    case postedAComment = "commented"
    case reviewedAnEdit = "reviewed"
    case editedAPost = "revision"
    case suggestedAnEdit = "suggested"
    
    var title: String {
        switch self {
        case .acceptedAnAnswer:
            return "Accepted an answer"
        case .postedAnAnswer:
            return "Posted an answer"
        case .askedAQuestion:
            return "Asked a question"
        case .earnedABadge:
            return "Earned a badge"
        case .postedAComment:
            return "Posted a comment"
        case .reviewedAnEdit:
            return "Reviewed a suggested edit"
        case .editedAPost:
            return "Edited a post"
        case .suggestedAnEdit:
            return "Suggested an edit"
        }
    }
}
