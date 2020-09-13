//
//  InboxView.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-09-13.
//

import SwiftUI

struct InboxView: View {
    @EnvironmentObject var viewManager: ViewManager
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
                    ForEach(viewManager.inbox, id: \.id) { messageSummary in
                        InboxMessageRow(imageManager: .init(messageSummary.profileImage),
                                        messageSummary: messageSummary)
                    }
                    .listRowBackground(Color.stackITCode)
                }.id(UUID())
                
                if viewManager.loadingSections.contains(.inbox) {
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
