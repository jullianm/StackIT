//
//  AuthenticationAction.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-09-26.
//

import Foundation

enum AuthenticationAction: Equatable {
    case checkAuthentication
    case signIn(url: URL)
    case logOut
}
