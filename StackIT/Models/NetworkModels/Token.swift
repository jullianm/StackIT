//
//  Token.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-08-08.
//

import Foundation

struct Token {
    let value: String
    let expiration: String
    
    var isNotEmpty: Bool {
        return value != "" && expiration != ""
    }
}

extension Token {
    static let empty = Token(value: .init(), expiration: .init())
}
