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
    @State private var showCommentsSheet = false
    @State private var showNewAnswerSheet = false
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

            VStack(alignment: .leading) {
                ForEach(question.body, id: \.self) { messageDetail in
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
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.2), lineWidth: 1))
            
            HStack {
                Spacer()
                
                Button {
                    showCommentsSheet.toggle()
                } label: {
                    HStack {
                        Image(systemName: "message.fill")
                        Text("\(question.commentCount)")
                        Spacer()
                    }
                }.onTapGesture {
                    showCommentsSheet.toggle()
                }.popover(isPresented: $showCommentsSheet) {
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
                
                Spacer()
                
                Button {
                    self.showNewAnswerSheet.toggle()
                } label: {
                    Image(systemName: "arrowshape.turn.up.left")
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.trailing)
                .sheet(isPresented: $showNewAnswerSheet) {
                    NewAnswerView {
                        self.showNewAnswerSheet = false
                    }
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
                        showCommentsSheet = false
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
