//
//  URL.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-08-10.
//

import Foundation

extension URL {
    var queryParameters: [String: String]? {
        guard
            var components = URLComponents(url: self, resolvingAgainstBaseURL: true),
            let fragment = components.fragment else { return nil }
        
        components.query = fragment
        return components.queryItems?.reduce(into: [String: String]()) { $0[$1.name] = $1.value }
    }
    
    func appending(_ queryItem: String, value: String?) -> URL {
        guard var urlComponents = URLComponents(string: absoluteString) else {
            return absoluteURL
        }
        
        var queryItems = urlComponents.queryItems ??  []
        let queryItem = URLQueryItem(name: queryItem, value: value)
        queryItems.append(queryItem)
        urlComponents.queryItems = queryItems
        
        return urlComponents.url!
    }
}
