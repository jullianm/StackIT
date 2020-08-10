//
//  Bundle.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-08-10.
//

import Foundation

extension Bundle {
    func data(from file: String) -> Data {
        guard let url = self.url(forResource: file, withExtension: nil) else {
            fatalError("Failed to locate \(file) in bundle.")
        }
        
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(file) from bundle.")
        }
        
        return data
    }
    
    func load(resource: String, ofType type: String) -> StackConfig {
        guard let path = path(forResource: resource, ofType: type),
              let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
            fatalError("File not found.")
        }
        
        do {
            let decoder = PropertyListDecoder()
            let model = try decoder.decode(StackConfig.self, from: data)
            return model
        } catch {
            fatalError("Failed to load \(resource) from bundle.")
        }
    }
}
