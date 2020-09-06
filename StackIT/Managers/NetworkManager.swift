//
//  Webservice.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-07-25.
//

import Foundation
import Combine

private typealias CacheID = String

protocol ServiceManager {
    func fetch<T: Decodable>(endpoint: Endpoint, model: T.Type) -> AnyPublisher<T, Error>
    func send<T:Decodable>(endpoint: Endpoint, model: T.Type) -> AnyPublisher<T, Error>
}

final class NetworkManager: ServiceManager {
    private var cache: [CacheID: Any] = [:]
    
    func fetch<T: Decodable>(endpoint: Endpoint, model: T.Type) -> AnyPublisher<T, Error> {
        if endpoint.sectionStatus == .refreshing {
            cache = [:]
        } else {
            if let value = cache[endpoint.cacheID] as? T {
                return Just(value)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
        }
        
        guard let url = endpoint.url else {
            return Fail(error: Error.wrongURL).eraseToAnyPublisher()
        }
                
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .mapError(Error.network)
            .map(\.data)
            .decode(type: model, decoder: decoder)
            .mapError(Error.decodingError)
            .print("#DEBUG GET REQUEST")
            .handleEvents(receiveOutput: { [weak self] model in
                self?.cache[endpoint.cacheID] = model
            })
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    func send<T:Decodable>(endpoint: Endpoint, model: T.Type) -> AnyPublisher<T, Error> {
        guard let request = endpoint.urlRequest else {
            return Fail(error: Error.wrongURL).eraseToAnyPublisher()
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .mapError(Error.network)
            .map(\.data)
            .decode(type: model, decoder: decoder)
            .mapError(Error.decodingError)
            .print("#DEBUG POST REQUEST")
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    private func isResponseValid(_ response: URLResponse) -> Bool {
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 500
        
        switch statusCode {
        case 200..<300:
            return true
        case _:
            return false
        }
    }
}
