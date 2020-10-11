//
//  AccountViewManager.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-09-29.
//

import Combine
import Foundation
import StackAPI

class AccountViewManager: ObservableObject {
    /// Published properties
    @Published var loadingSections: Set<AccountLoadingSection> = []
    @Published var user: UserSummary?
    @Published var inbox: [UserMessageSummary] = []
    @Published var timeline: [TimelineSummary] = []

    /// Private properties
    private var subscriptions = Set<AnyCancellable>()
    private var authManager: AuthenticationManager
    private var proxy: ViewManagerProxy

    var fetchAccountSectionSubject = PassthroughSubject<AppSection, Never>()
    var authenticationSubject = CurrentValueSubject<AppSection, Never>(
        .authentication(action: .checkAuthentication)
    )
    
    init(authenticationManager: AuthenticationManager = .shared, enableMock: Bool = false) {
        authManager = authenticationManager
        proxy = ViewManagerProxy(api: .init(enableMock: enableMock))
        setupBindings()
    }
    
    private func setupBindings() {
        bindUser()
        bindAuthentication()
        bindFetchAccount()
    }
}

// MARK: - Account-related bindings
extension AccountViewManager {
    private func bindUser() {
        authManager.addUserPublisher
            .handleEvents(receiveOutput: { [weak self] _ in
                guard let self = self else { return }
                self.proxy.credentials = self.authManager.credentials
                self.loadingSections.remove(.account)
            })
            .assign(to: \.user, on: self)
            .store(in: &subscriptions)
    }
    
    private func bindFetchAccount() {
        fetchAccountSectionSubject
            .handleEvents(receiveOutput: { [weak self] section in
                switch section {
                case .account(let subsection):
                    switch subsection {
                    case .messages:
                        self?.loadingSections.insert(.inbox)
                    case .timeline:
                        self?.loadingSections.insert(.timeline)
                    case .profile:
                        /// ⚠️ We already have current user informations in `User` object.
                        return
                    }
                default:
                    return
                }
            })
            .sink { [weak self] section in
                guard let self = self else { return }
                
                switch section {
                case .account(let subsection):
                    switch subsection {
                    case .messages:
                        self.proxy.fetchInbox()
                            .handleEvents(receiveOutput: { [weak self] _ in
                                self?.loadingSections.remove(.inbox)
                            })
                            .replaceError(with: [])
                            .assign(to: \.inbox, on: self)
                            .store(in: &self.subscriptions)
                    case .timeline:
                        self.proxy.fetchTimeline()
                            .handleEvents(receiveOutput: { [weak self] _ in
                                self?.loadingSections.remove(.timeline)
                            })
                            .replaceError(with: [])
                            .assign(to: \.timeline, on: self)
                            .store(in: &self.subscriptions)
                    case .profile:
                        return
                    }
                default:
                    return
                }
            }.store(in: &subscriptions)
    }
    
    private func bindAuthentication() {
        authenticationSubject
            .sink { [weak self] section in
                switch section {
                case .authentication(let action):
                    switch action {
                    case .checkAuthentication:
                        self?.authManager.checkTokenSubject.send(())
                        self?.loadingSections.insert(.account)
                    case .signIn(let url):
                        self?.authManager.parseTokenSubject.send(url)
                        self?.loadingSections.insert(.account)
                    case .logOut:
                        self?.authManager.removeUserSubject.send(())
                    }
                default:
                    break
                }
            }.store(in: &subscriptions)
    }
}
