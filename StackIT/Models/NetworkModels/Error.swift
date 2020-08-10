//
//  Error.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-07-25.
//

import Foundation

enum Error: Swift.Error {
    case wrongURL
    case corruptedData(Swift.Error?)
    case decodingError(Swift.Error?)
    case network(Swift.Error?)
}
