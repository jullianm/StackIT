//
//  QuestionRow.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-08-11.
//

import SwiftUI

struct QuestionRow: View {
    @ObservedObject var imageManager: ImageManager
    @ObservedObject var commentsViewManager: CommentsViewManager
    @State private var showComments = false
    var question: QuestionsSummary
    
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                VStack {
                    HStack {
                        Button {
                            
                        } label: {
                            Image(systemName: "arrowtriangle.up.fill")
                        }
                        
                        Text(question.score)
                        
                        Button {
                            
                        } label: {
                            Image(systemName: "arrowtriangle.down.fill")
                        }
                    }
                }
                
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
                        
                        Text(question.authorName).font(.subheadline)
                        
                    }
                }.padding([.leading, .trailing])
            }
            
            NSTextFieldRepresentable(htmlString: question.body)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.2), lineWidth: 1))
            Button {
                showComments.toggle()
            } label: {
                HStack {
                    Image(systemName: "message.fill")
                    Text("\(question.commentCount)")
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
                        .comments(subsection: .question(question))
                    )
                }
            }
        }.padding()
    }
}

extension QuestionRow {
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
