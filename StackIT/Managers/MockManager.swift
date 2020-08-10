//
//  MockService.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-07-26.
//

import Combine
import Foundation

final class MockManager: ServiceManager {
    func fetch<T: Decodable>(endpoint: Endpoint, model: T.Type) -> AnyPublisher<T, Error> {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return Just(endpoint.mockData).map { data in
            return try! decoder.decode(model, from: data)
        }
        .setFailureType(to: Error.self)
        .eraseToAnyPublisher() 
    }
    
    func send<T:Decodable>(endpoint: Endpoint, model: T.Type) -> AnyPublisher<T, Error> {
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
            .print("#DEBUG")
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
