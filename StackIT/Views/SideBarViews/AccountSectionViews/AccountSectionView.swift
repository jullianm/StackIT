//
//  AccountSectionView.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-08-10.
//

import SwiftUI

struct AccountSectionView: View {
    @EnvironmentObject var viewManager: ViewManager
    @Environment(\.openURL) private var openURL
    @State private var isLogoutHovered = false
    @State private var showProfileSheet = false
    
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
                                showProfileSheet = true
                                viewManager.fetchAccountSectionSubject.send(.account(subsection: section))
                            }
                    }
                }
                .redacted(reason: viewManager.loadingSections.contains(.account) ? .placeholder: [])
                .popover(isPresented: $showProfileSheet, arrowEdge: .leading) {
                    ZStack {
                        Color.stackITCode
                        inboxSection
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

extension AccountSectionView {
    var inboxSection: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Messages").font(.largeTitle).padding(.leading)
                Spacer()
                Button {
                    showProfileSheet = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                }.buttonStyle(BorderlessButtonStyle())
            }.padding(.bottom)
            
            List {
                ForEach(viewManager.inbox, id: \.id) { messageSummary in
                    InboxMessageRow(imageManager: .init(messageSummary.profileImage),
                                    messageSummary: messageSummary)
                }
                .listRowBackground(Color.stackITCode)
            }
        }
        .frame(width: 800, height: 500)
        .padding()
    }
}

struct AccountSectionView_Previews: PreviewProvider {
    static var previews: some View {
        AccountSectionView()
    }
}
