//
//  StackConfig.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-08-04.
//

import Foundation

struct StackConfig: Decodable {
    let clientId: String
    let key: String
    var token: String?
}
