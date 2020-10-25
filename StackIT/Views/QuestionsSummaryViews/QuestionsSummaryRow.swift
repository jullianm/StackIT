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
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(questionSummary.title).lineLimit(nil)
                    
                    Text(questionSummary.tags.joined(separator: ", "))
                        .foregroundColor(Color.gray)
                        .font(.caption)
                        .opacity(questionSummary.isNoResultFound ? 0: 1)
                    
                    HStack(spacing: 10) {
                        HStack(spacing: 2) {
                            Image(systemName: "text.bubble.fill")
                            Text(questionSummary.answers).fixedSize()
                        }
                        
                        HStack(spacing: 2) {
                            Image(systemName: "eye.fill")
                            Text(questionSummary.views).fixedSize()
                        }
                        
                        HStack(spacing: 2) {
                            Image(systemName: "arrowtriangle.up.fill")
                            Text(questionSummary.score)
                        }
                    }.opacity(questionSummary.isNoResultFound ? 0: 1)
                                        
                    Spacer()
                    
                    HStack(spacing: 5) {
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
                }
                
                Spacer()
                
                ZStack(alignment: .topTrailing) {
                    if questionsViewManager.loadingSections.isEmpty {
                        Image("StackVotes")
                            .renderingMode(.template)
                            .resizable()
                            .opacity(questionSummary.isNoResultFound ? 0: 0.1)
                            .frame(width: 100, height: 100)
                            .offset(x: -20, y: -20)
                    }
                    
                    VStack {
                        Button {
                            
                        } label: {
                            Image(systemName: "arrowtriangle.up.fill")
                        }.buttonStyle(PlainButtonStyle())
                        
                        Spacer()
                        
                        Button {
                            
                        } label: {
                            Image(systemName: "arrowtriangle.down.fill")
                        }.buttonStyle(PlainButtonStyle())
                        
                    }.opacity(questionSummary.isNoResultFound ? 0: 1)
                }
                
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
