//
//  AnswersView.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-07-26.
//

import SwiftUI

struct AnswersView: View {
    @ObservedObject var answersViewManager: AnswersViewManager
    
    var body: some View {
        ZStack {
            List {
                VStack {
                    if let question = answersViewManager.selectedQuestion, !answersViewManager.answersSummary.isEmpty  {
                        HStack {
                            Text("Question").font(.largeTitle).padding(.leading)
                            Spacer()
                        }
                        QuestionRow(imageManager: .init(question.authorImage),
                                    commentsViewManager: CommentsViewManager(),
                                    question: question)
                    }
                    if !answersViewManager.answersSummary.isEmpty {
                        HStack {
                            Text("Answers").font(.largeTitle).padding(.leading)
                            Spacer()
                        }
                    }
                    ForEach(answersViewManager.answersSummary, id: \.id) { answer in
                        AnswerRow(imageManager: .init(answer.authorImage),
                                  commentsViewManager: CommentsViewManager(),
                                  answer: answer)
                    }

                }.id(UUID())
            }
            
            if answersViewManager.loadingSections.contains(.answers) {
                ProgressView()
            }
            
            if answersViewManager.answersSummary.isEmpty && !answersViewManager.loadingSections.contains(.answers) {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Image(systemName: "eye.slash")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(Color.gray)
                            .frame(width: 40, height: 25)
                        Spacer()
                    }
                    Spacer()
                }
            }
        }.frame(minWidth: 500, idealWidth: 550, maxWidth: .infinity)
    }
}
