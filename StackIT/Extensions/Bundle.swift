//
//  Bundle.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-09-27.
//

import Foundation
import StackAPI

extension Bundle {
    func load(resource: String, ofType type: String) -> StackCredentials {
        guard let path = path(forResource: resource, ofType: type),
              let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
            fatalError("File not found.")
        }
        
        do {
            let decoder = PropertyListDecoder()
            let model = try decoder.decode(StackCredentials.self, from: data)
            return model
        } catch {
            fatalError("Failed to load \(resource) from bundle.")
        }
    }
}
