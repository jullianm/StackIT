//
//  AccountSectionView.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-08-10.
//

import SwiftUI
import Foundation

struct AccountSectionView: View {
    @ObservedObject var accountViewManager: AccountViewManager
    @Environment(\.openURL) private var openURL
    @State private var isLogoutHovered = false
    @State private var showProfileSheet = false
    @State private var accountSection: AccountSection?
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Account")
                    .foregroundColor(Color.gray)
                    .font(.subheadline)
                    .padding(.leading)
                
                Spacer()
                
                if accountViewManager.user != nil { /// user is logged in
                    if isLogoutHovered {
                        Text("Log out from account").font(.footnote).foregroundColor(Color.red)
                    }
                    
                    Button(action: {
                        accountViewManager.authenticationSubject.send(.authentication(action: .logOut))
                    }) {
                        Image(systemName: "xmark.circle.fill")
                    }
                    .cornerRadius(5.0)
                    .buttonStyle(BorderlessButtonStyle())
                    .padding(.trailing)
                    .onHover { hovered in
                        withAnimation {
                            isLogoutHovered = hovered
                        }
                    }
                }
            }
            
            Divider()
                .background(Color.gray)
                .opacity(0.1)
                .padding(.leading)
            
            if accountViewManager.user != nil {
                VStack(alignment: .leading) {
                    ForEach(AccountSection.allCases, id: \.self) { section in
                        Text(section.title)
                            .padding(.leading)
                            .padding(.bottom, 5)
                            .onTapGesture {
                                accountSection = section
                                accountViewManager.fetchAccountSectionSubject.send(.account(subsection: section))
                            }
                    }
                }
                .redacted(reason: accountViewManager.loadingSections.contains(.account) ? .placeholder: [])
                .popover(item: $accountSection, arrowEdge: .leading) { section in
                    switch section {
                    case .timeline:
                        ZStack {
                            Color.stackITCode
                            TimelineView(accountViewManager: accountViewManager) {
                                accountSection = nil
                            }
                        }
                    case .messages:
                        ZStack {
                            Color.stackITCode
                            InboxView(accountViewManager: accountViewManager) {
                                accountSection = nil
                            }
                        }
                    case .profile:
                        ZStack {
                            Color.stackITCode
                            let imageStr = accountViewManager.user?.profileImage ?? .init()
                            ProfileView(imageManager: .init(imageStr),
                                        accountViewManager: accountViewManager) {
                                accountSection = nil
                            }
                        }
                    
                    }
                }
            } else {
                HStack {
                    Button(action: {
                        openURL(AuthenticationManager.shared.getSignInUrl())
                    }) {
                        Text("Sign in").foregroundColor(Color.white)
                    }
                    .background(Color("StackITBlue").opacity(0.6))
                    .cornerRadius(5.0)
                    
                    Button(action: {
                        openURL(AuthenticationManager.shared.getSignUpUrl())
                    }) {
                        Text("Sign up")
                    }.cornerRadius(5.0)
                }
                .redacted(reason: accountViewManager.loadingSections.contains(.account) ? .placeholder: [])
                .padding(.leading)
            }
            
        }.padding([.top])
    }
}

struct AccountSectionView_Previews: PreviewProvider {
    static var previews: some View {
        AccountSectionView(accountViewManager: .init())
    }
}
