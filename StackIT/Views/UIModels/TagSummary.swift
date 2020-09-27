//
//  TagSummary.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-09-26.
//

import Foundation


class TagSummary: Comparable {
    let id = UUID()
    let name: String
    var isFavorite: Bool
    
    init(name: String, isFavorite: Bool = false) {
        self.name = name
        self.isFavorite = isFavorite
    }
    
    static func < (lhs: TagSummary, rhs: TagSummary) -> Bool {
        return lhs.name < rhs.name
    }
    
    static func == (lhs: TagSummary, rhs: TagSummary) -> Bool {
        return lhs.name == rhs.name
    }
}

extension TagSummary {
    static let popular: [TagSummary] = [
        TagSummary(name: "javascript"),
        TagSummary(name: "java"),
        TagSummary(name: "python"),
        TagSummary(name: "c#"),
        TagSummary(name: "php"),
        TagSummary(name: "android"),
        TagSummary(name: "html"),
        TagSummary(name: "jquery"),
        TagSummary(name: "c++"),
        TagSummary(name: "css"),
        TagSummary(name: "ios"),
        TagSummary(name: "mysql"),
        TagSummary(name: "sql"),
        TagSummary(name: "r"),
        TagSummary(name: "asp.net"),
        TagSummary(name: "node.js"),
        TagSummary(name: "arrays"),
        TagSummary(name: "c"),
        TagSummary(name: "ruby-on-rails"),
        TagSummary(name: ".net"),
        TagSummary(name: "json"),
        TagSummary(name: "objective-c"),
        TagSummary(name: "sql-server"),
        TagSummary(name: "swift"),
        TagSummary(name: "angularjs"),
        TagSummary(name: "python-3.x"),
        TagSummary(name: "django"),
        TagSummary(name: "reactjs"),
        TagSummary(name: "excel"),
        TagSummary(name: "regex")
    ]
}
