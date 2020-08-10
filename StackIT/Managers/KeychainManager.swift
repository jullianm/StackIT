//
//  KeychainManager.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-08-08.
//

import Foundation
import KeychainAccess

class KeychainManager {
    private(set) static var shared = KeychainManager()
    private let keychainNameKey = "com.croissants.stackit"
    private let keychainAccessTokenKey = "access_token"
    private let keychainTokenExpirationKey = "token_expiration"
    
    func retrieveToken() -> String? {
        let keychain = Keychain(service: keychainNameKey)
        return keychain[keychainAccessTokenKey]
    }
    
    func storeToken(_ token: Token) {
        let keychain = Keychain(service: keychainNameKey)
        keychain[keychainAccessTokenKey] = token.value
        keychain[keychainTokenExpirationKey] = token.expiration
    }
    
    func removeToken() {
        let keychain = Keychain(service: keychainNameKey)
        keychain[keychainAccessTokenKey] = nil
        keychain[keychainTokenExpirationKey] = nil
    }
    
    func isTokenNotExpired() -> Bool {
//        return keychain[keychainTokenExpirationKey]
        return true
    }
}
