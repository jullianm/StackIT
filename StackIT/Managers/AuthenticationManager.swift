//
//  AuthenticationService.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-08-01.
//

import Foundation
import Combine

class AuthenticationManager {
    private(set) static var shared = AuthenticationManager()
    private let scopes = ["read_inbox", "private_info"]
    private let redirectUri = "stackit://stackexchange.com"
    private let keychainManager = KeychainManager.shared
    private var subscriptions = Set<AnyCancellable>()
    var stackConfig: StackConfig
    
    /// Subjects properties
    var parseTokenSubject = PassthroughSubject<URL, Never>()
    var addUserSubject = PassthroughSubject<UserSummary?, Never>()
    var removeUserSubject = PassthroughSubject<Void, Never>()
    var checkTokenSubject = PassthroughSubject<Void, Never>()
    
    private init() {
        stackConfig = Bundle.main.load(resource: "StackConfig", ofType: "plist")
        bindParseToken()
        bindRemoveUser()
        bindCheckToken()
    }
    
    func bindCheckToken() {
        checkTokenSubject
            .map { [self] in
                return keychainManager.retrieveToken() ?? .init()
            }
            .handleEvents(receiveOutput: { [self] token in
                if token.isEmpty {
                    addUserSubject.send(nil)
                } else {
                    stackConfig.token = token
                }
            })
            .filter { !$0.isEmpty }
            .map { [self] in getUser(token: $0) }
            .switchToLatest()
            .sink(receiveValue: addUserSubject.send)
            .store(in: &subscriptions)
    }
    
    func bindRemoveUser() {
        removeUserSubject
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
        stackConfig.token = token.value
    }
}

// MARK: - Helpers
extension AuthenticationManager {
    func getSignInUrl() -> URL {
        return URL(string: "https://stackoverflow.com/oauth/dialog")!
            .appending("client_id", value: stackConfig.clientId)
            .appending("redirect_uri", value: redirectUri)
            .appending("scope", value: scopes.joined(separator: " "))
    }
    
    func getSignUpUrl() -> URL {
        return URL(string: "https://stackoverflow.com/users/signup")!
    }
    
    private func getUser(token: String) -> AnyPublisher<UserSummary?, Never> {
        return NetworkManager().fetch(endpoint: .user(token: token, key: self.stackConfig.key), model: User.self)
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
