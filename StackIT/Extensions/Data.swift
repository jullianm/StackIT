//
//  Data.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-09-30.
//

import Foundation

extension Optional where Wrapped == Data {
    func toArray() -> [String] {
        guard let self = self else { return [] }
        
        return (try? JSONDecoder().decode([String].self, from: self)) ?? []
    }
}


