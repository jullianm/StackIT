//
//  AuthenticationService.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-08-01.
//

import Foundation
import Combine
import StackAPI

class AuthenticationManager {
    private(set) static var shared = AuthenticationManager()
    private let scopes = ["read_inbox", "private_info"]
    private let redirectUri = "stackit://stackexchange.com"
    private let keychainManager = KeychainManager.shared
    private var subscriptions = Set<AnyCancellable>()
    var credentials: StackCredentials
    
    /// Subjects properties
    var parseTokenSubject = PassthroughSubject<URL, Never>()
    var removeUserSubject = PassthroughSubject<Void, Never>()
    var checkTokenSubject = PassthroughSubject<Void, Never>()
    private var addUserSubject = PassthroughSubject<UserSummary?, Never>()
    var addUserPublisher: AnyPublisher<UserSummary?, Never> {
        addUserSubject.eraseToAnyPublisher()
    }
    
    private init() {
        credentials = Bundle(for: StackITAPI.self).load(resource: "StackCredentials", ofType: "plist")
        bindParseToken()
        bindRemoveUser()
        bindCheckToken()
    }
    
    func bindCheckToken() {
        checkTokenSubject
            .map { [weak self] _ -> String in
                guard let self = self else { return .init() }
                return self.keychainManager.retrieveToken() ?? .init()
            }
            .handleEvents(receiveOutput: { token in
                self.credentials.token = token
            })
            .map { [weak self] token -> AnyPublisher<UserSummary?, Never> in
                guard let self = self else { return Just(nil).eraseToAnyPublisher() }
                if token.isEmpty {
                    return Just(nil).eraseToAnyPublisher()
                } else {
                    return self.getUser(token: token)
                }
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: addUserSubject.send)
            .store(in: &subscriptions)
    }
    
    func bindRemoveUser() {
        removeUserSubject
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.addUserSubject.send(nil)
            })
            .sink(receiveValue: keychainManager.removeToken)
            .store(in: &subscriptions)
    }
    
    private func bindParseToken() {
        parseTokenSubject
            .map(parsedToken(in:))
            .replaceNil(with: .empty)
            .filter(\.isNotEmpty)
            .handleEvents(receiveOutput: storeToken)
            .map(\.value)
            .map(getUser(token:))
            .switchToLatest()
            .sink(receiveValue: addUserSubject.send)
            .store(in: &subscriptions)
    }
    
    private func storeToken(_ token: Token) {
        keychainManager.storeToken(token)
        credentials.token = token.value
    }
}

// MARK: - Helpers
extension AuthenticationManager {
    func getSignInUrl() -> URL {
        return URL(string: "https://stackoverflow.com/oauth/dialog")!
            .appending("client_id", value: credentials.clientId)
            .appending("redirect_uri", value: redirectUri)
            .appending("scope", value: scopes.joined(separator: " "))
    }
    
    func getSignUpUrl() -> URL {
        return URL(string: "https://stackoverflow.com/users/signup")!
    }
    
    private func getUser(token: String) -> AnyPublisher<UserSummary?, Never> {
        return StackITAPI().fetchUser(credentials: credentials)
            .map { $0.items.map(UserSummary.init) }
            .replaceError(with: [])
            .map(\.first)
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }
    
    private func parsedToken(in url: URL) -> Token? {
        guard let token = url.queryParameters?.first(where: { $0.key == "access_token" }),
              let expiration = url.queryParameters?.first(where: { $0.key == "expires" }) else { return nil }
        
        return Token(value: token.value, expiration: expiration.value)
    }
}
