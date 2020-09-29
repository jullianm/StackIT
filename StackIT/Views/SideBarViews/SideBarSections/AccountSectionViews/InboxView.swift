//
//  InboxView.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-09-13.
//

import SwiftUI

struct InboxView: View {
    @ObservedObject var accountViewManager: AccountViewManager
    var onCloseTapped: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Messages").font(.largeTitle).padding(.leading)
                Spacer()
                Button {
                    onCloseTapped()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                }.buttonStyle(BorderlessButtonStyle())
            }.padding(.bottom)
            
            ZStack {
                List {
                    ForEach(accountViewManager.inbox, id: \.id) { messageSummary in
                        InboxMessageRow(imageManager: .init(messageSummary.profileImage),
                                        messageSummary: messageSummary)
                    }
                    .listRowBackground(Color.stackITCode)
                }.id(UUID())
                
                if accountViewManager.loadingSections.contains(.inbox) {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                        Spacer()
                    }
                }
            }
        }
        .frame(width: 800, height: 500)
        .padding()
    }
}
