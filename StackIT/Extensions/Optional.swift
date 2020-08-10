//
//  Optional.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-08-10.
//

import Foundation

extension Optional {
    func replaceNil<Element>() -> Wrapped where Wrapped == Array<Element> {
        guard let self = self else {
            return []
        }
        return self
    }
}

extension Optional where Wrapped == String {
    func unwrapped() -> String {
        guard let self = self else {
            return .init()
        }
        return self
    }
}
extension Optional where Wrapped == Int {
    func string() -> String {
        guard let self = self else {
            return .init()
        }
        return String(self)
    }
}
