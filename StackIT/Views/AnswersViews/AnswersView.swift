//
//  AnswersView.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-07-26.
//

import SwiftUI

struct AnswersView: View {
    @EnvironmentObject var viewManager: ViewManager
    
    var body: some View {
        ZStack {
            List {
                if let question = viewManager.questionsSummary.first(where: \.isSelected), !viewManager.answersSummary.isEmpty  {
                    HStack {
                        Text("Question").font(.largeTitle).padding(.leading)
                        Spacer()
                    }
                    QuestionRow(imageManager: .init(question.authorImage), question: question)
                    
                }
                if !viewManager.answersSummary.isEmpty {
                    HStack {
                        Text("Answers").font(.largeTitle).padding(.leading)
                        Spacer()
                    }
                }
                ForEach(viewManager.answersSummary, id: \.id) { answer in
                    AnswerRow(imageManager: .init(answer.authorImage), answer: answer)
                }
            }.blur(radius: viewManager.loadingSections.contains(.answers) ? 2.0: 0)
            
            if viewManager.loadingSections.contains(.answers) {
                ProgressView()
            }
            
            if viewManager.answersSummary.isEmpty && !viewManager.loadingSections.contains(.answers) {
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

struct AnswersView_Previews: PreviewProvider {
    static var previews: some View {
        AnswersView(viewManager: .init())
    }
}
