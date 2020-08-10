//
//  Tag.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-07-26.
//

import Foundation

struct Tags: Codable {
    let items: [Name]
}

struct Name: Codable {
    let name: String
}
