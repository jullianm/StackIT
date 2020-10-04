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
        VStack(alignment: .leading) {
            HStack {
                Text(messageSummary.creationDate)
                    .foregroundColor(.blue)
                    .italic()
                    .font(.subheadline)
                    .padding(.leading, 5)
                
                if messageSummary.isUnread {
                    Text("New")
                        .foregroundColor(.white)
                        .font(.headline)
                        .italic()
                }
            }
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Question").font(.subheadline).foregroundColor(Color.gray)
                    Text(messageSummary.title)
                }
                
                VStack(alignment: .leading) {
                    HStack {
                        Text(messageSummary.messageType).font(.subheadline).foregroundColor(Color.gray)
                        
                        Spacer()
                        
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
                        
                        Text(messageSummary.authorName)
                    }
                    
                    if !messageSummary.messageDetails.isEmpty {
                        VStack(alignment: .leading) {
                            ForEach(messageSummary.messageDetails, id: \.self) { messageDetail in
                                switch messageDetail {
                                case .plainText(let text):
                                    NSTextFieldRepresentable(attributedString: text)
                                case .codeText(let code):
                                    CodeView(code: code)
                                case .image(let image):
                                    ImageView(imageManager: .init(image.url), legend: image.legend)
                                }
                            }
                        }.padding()
                    }
                    
                }
                
                Button {
                    openURL(messageSummary.url)
                } label: {
                    Text("See more").foregroundColor(Color.blue)
                }.buttonStyle(PlainButtonStyle())
                
            }
            .padding()
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.2), lineWidth: 1))
        }.padding()
    }
}
