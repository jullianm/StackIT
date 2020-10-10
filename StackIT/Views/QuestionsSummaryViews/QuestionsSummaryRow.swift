//
//  QuestionSummaryRow.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-08-10.
//

import SwiftUI

struct QuestionSummaryRow: View {
    var questionSummary: QuestionsSummary
    @ObservedObject var questionsViewManager: QuestionsViewManager
    @State private var showNewAnswerSheet = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(questionSummary.title).lineLimit(nil)
                    
                    Text(questionSummary.tags.joined(separator: ", "))
                        .foregroundColor(Color.gray)
                        .font(.caption)
                        .opacity(questionSummary.isNoResultFound ? 0: 1)
                    
                    HStack {
                        Button {
                            self.questionsViewManager.toggleFavoriteQuestionSubject.send(
                                questionSummary.questionId
                            )
                        } label: {
                            Image(systemName: questionSummary.isFavorite ? "heart.fill" :"heart")
                        }.buttonStyle(PlainButtonStyle())
                        
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
                    }.opacity(questionSummary.isNoResultFound ? 0: 1)
                    
                    Spacer()
                    
                    Text(questionSummary.lastActivityDate)
                        .foregroundColor(Color.gray)
                        .italic()
                        .font(.caption)
                        .opacity(questionSummary.isNoResultFound ? 0: 1)
                }
                
                Spacer()
                
                VStack(alignment:.leading, spacing: 7) {
                    HStack {
                        ZStack {
                            Rectangle()
                                .foregroundColor(Color.blue.opacity(0.5))
                                .cornerRadius(10.0)
                            VStack {
                                Text(questionSummary.score).font(.headline)
                                Text("votes").font(.subheadline)
                            }
                        }
                        .frame(width : 70, height: 50)
                        .padding(.bottom, 5)
                        
                        VStack(spacing: 10) {
                            Button {
                                
                            } label: {
                                Image(systemName: "arrowtriangle.up.fill")
                            }.buttonStyle(PlainButtonStyle())
                            
                            Button {
                                
                            } label: {
                                Image(systemName: "arrowtriangle.down.fill")
                            }.buttonStyle(PlainButtonStyle())
                        }.frame(height: 50)
                    }
                
                    HStack(spacing: 8.5) {
                        Image(systemName: "text.bubble.fill")
                        Text(questionSummary.answers).fixedSize()
                    }
                    
                    HStack(spacing: 5) {
                        Image(systemName: "eye.fill")
                        Text(questionSummary.views).fixedSize()
                    }
                }.opacity(questionSummary.isNoResultFound ? 0: 1)
            
            }.padding(.top, 10)
            
            Divider().opacity(questionSummary.isNoResultFound ? 0: 1)
        }.contentShape(Rectangle())
    }
}

struct QuestionsSummaryRow_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
