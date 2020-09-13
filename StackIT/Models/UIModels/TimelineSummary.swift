//
//  ActivitySummary.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-09-13.
//

import Foundation

struct TimelineSummary: Identifiable {
    let id = UUID()
    let timelineType: String
    let creationDate: String
}

extension TimelineSummary {
    init(from item: TimelineItems) {
        timelineType = item.timelineType.title
        creationDate = item.creationDate.stringDate()
    }
}
