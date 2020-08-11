//
//  StackITApp.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-07-25.
//

import SwiftUI

@main
struct StackITApp: App {
    private let viewManager = ViewManager()
    
    var body: some Scene {
        WindowGroup {
            AppView()
                .environmentObject(viewManager)
                .onOpenURL { url in
                    viewManager.authenticationSubject.send(.authentication(action: .signIn(url: url)))
                }
        }
    }
}
