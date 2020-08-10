//
//  InboxMessageRow.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-08-10.
//

import SwiftUI

struct InboxMessageRow: View {
    @ObservedObject var imageManager: ImageManager
    @Environment(\.openURL) private var openURL
    var messageSummary: UserMessageSummary
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 10) {
                //                            if messageSummary.isUnread {
                //                                Image(systemName: "circle.fill")
                //                                    .renderingMode(.template)
                //                                    .foregroundColor(Color.blue)
                //                            }
                
                Text("Question").font(.subheadline).foregroundColor(Color.gray)
                Text(messageSummary.title)
            }
            
            VStack(alignment: .leading) {
                Text(messageSummary.messageType).font(.subheadline).foregroundColor(Color.gray)
                
                HStack(spacing: 10) {
                    if let image = imageManager.image {
                        Image(nsImage: image)
                            .resizable()
                            .frame(width: 20, height: 20)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 1))
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 1))
                    }
                    
                    NSTextFieldRepresentable(htmlString: messageSummary.body)
                }
            }
            
            Button {
                openURL(messageSummary.url)
            } label: {
                Text("See more").foregroundColor(Color.blue)
            }.buttonStyle(PlainButtonStyle())
            
            Divider()
                .background(Color.gray)
                .opacity(0.1)
                .padding(.leading)
        }.padding()
    }
}
