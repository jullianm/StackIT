//
//  AnswerRow.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-08-10.
//

import SwiftUI

struct AnswerRow: View {
    @ObservedObject var imageManager: ImageManager
    @ObservedObject var commentsViewManager: CommentsViewManager
    @State private var showComments = false
    var answer: AnswersSummary
    
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                /*VStack {
                    HStack {
                        Button {
                            
                        } label: {
                            Image(systemName: "arrowtriangle.up.fill")
                        }
                        
                        Text(answer.score)
                        
                        Button {
                            
                        } label: {
                            Image(systemName: "arrowtriangle.down.fill")
                        }
                    }
                }*/
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    HStack {
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
                        
                        Text(answer.authorName).font(.subheadline)
                        
                    }
                }.padding([.leading, .trailing])
            }

            VStack(alignment: .leading) {
                ForEach(answer.messageDetails, id: \.self) { messageDetail in
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
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(answer.isAccepted ? Color("StackITGreen"): Color.gray.opacity(0.2), lineWidth: 1))

            /*Button {
                showComments.toggle()
            } label: {
                HStack {
                    Image(systemName: "message.fill")
                    Text(answer.commentCount)
                    Spacer()
                }
            }.onTapGesture {
                showComments.toggle()
            }.popover(isPresented: $showComments) {
                ZStack {
                    Color.stackITCode
                    commentsSection
                }
                .frame(width: 500, height: 350)
                .onAppear {
                    commentsViewManager.fetchCommentsSubject.send(
                        .comments(subsection: .answer(answer))
                    )
                }
            }*/
        }.padding()
    }
}

extension AnswerRow {
    private var commentsSection: some View {
        VStack(alignment: .leading) {
            if !commentsViewManager.commentsSummary.isEmpty {
                HStack {
                    Text("Comments").font(.largeTitle)
                    Spacer()
                    Button {
                        showComments = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                    }.buttonStyle(BorderlessButtonStyle())
                    
                }.padding([.top, .leading, .trailing])
            }
            
            ZStack {
                if !commentsViewManager.commentsSummary.isEmpty {
                    List(commentsViewManager.commentsSummary, id: \.id) { comment in
                        CommentRow(imageManager: .init(comment.authorImage), comment: comment)
                    }
                }
                
                if commentsViewManager.loadingSections.contains(.comments) && commentsViewManager.commentsSummary.isEmpty {
                    ProgressView()
                }
            }
        }
    }
}
