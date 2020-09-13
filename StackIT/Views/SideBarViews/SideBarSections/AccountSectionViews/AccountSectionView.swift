//
//  AccountSectionView.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-08-10.
//

import SwiftUI
import Foundation

struct AccountSectionView: View {
    @EnvironmentObject var viewManager: ViewManager
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
                
                if isLogoutHovered {
                    Text("Log out from account").font(.footnote).foregroundColor(Color.red)
                }
                
                Button(action: {
                    viewManager.authenticationSubject.send(.authentication(action: .logOut))
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
            
            Divider()
                .background(Color.gray)
                .opacity(0.1)
                .padding(.leading)
            
            
            if viewManager.user != nil {
                VStack(alignment: .leading) {
                    ForEach(AccountSection.allCases, id: \.self) { section in
                        Text(section.title)
                            .padding(.leading)
                            .padding(.bottom, 5)
                            .onTapGesture {
                                accountSection = section
                                viewManager.fetchAccountSectionSubject.send(.account(subsection: section))
                            }
                    }
                }
                .redacted(reason: viewManager.loadingSections.contains(.account) ? .placeholder: [])
                .popover(item: $accountSection, arrowEdge: .leading) { section in
                    switch section {
                    case .activity:
                        ZStack {
                            Color.stackITCode
                            ActivityView {
                                accountSection = nil
                            }
                        }
                    case .messages:
                        ZStack {
                            Color.stackITCode
                            InboxView {
                                accountSection = nil
                            }
                        }
                    case .profile:
                        ZStack {
                            Color.stackITCode
                            let imageStr = viewManager.user?.profileImage ?? .init()
                            ProfileView(imageManager: .init(imageStr)) {
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
                .redacted(reason: viewManager.loadingSections.contains(.account) ? .placeholder: [])
                .padding(.leading)
            }
            
        }.padding([.top])
    }
}

struct AccountSectionView_Previews: PreviewProvider {
    static var previews: some View {
        AccountSectionView()
    }
}
