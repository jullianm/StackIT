//
//  PostSummaryView.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-07-25.
//

import SwiftUI
import AppKit

struct QuestionsSummaryView: View {
    @ObservedObject var questionsViewManager: QuestionsViewManager
    @State private var isActive = true
    @State private var selectedIndex: UUID?
    var answersViewManager: AnswersViewManager

    var body: some View {
        VStack {
            filterView
            listView
        }.frame(width: 500)
    }
}

extension QuestionsSummaryView {
    var filterView: some View {
        VStack {
            HStack {
                ForEach(QuestionsFilter.allCases, id: \.self) { questionFilter in
                    HStack {
                        Button(action: {
                            questionsViewManager.updateQuestionsFilter(questionFilter)
                        }) {
                            Image(systemName: questionsViewManager.questionsFilter.contains(questionFilter) ? "checkmark.square": "square")
                                .renderingMode(.template)
                                .resizable()
                                .frame(width: 13, height: 13)
                                .foregroundColor(Color.blue)
                        }.buttonStyle(PlainButtonStyle())
                        
                        Text(questionFilter.rawValue)
                    }
                }.padding()
            }
            
            Divider()
                .background(Color.gray)
                .opacity(0.1)
        }
    }
    
    var listView: some View {
        List {
            ForEach(questionsViewManager.questionsSummary, id: \.id) { questionSummary in
                QuestionSummaryRow(questionSummary: questionSummary)
                    .background(selectedIndex == questionSummary.id ? Color.white.opacity(0.3): Color.clear)
                    .onTapGesture {
                        selectedIndex = questionSummary.id
                        answersViewManager.fetchAnswersSubject.send(
                            .answers(question: questionSummary)
                        )
                    }
            }.redacted(reason: questionsViewManager.loadingSections.contains(.questions) ? .placeholder: [])
            
            if questionsViewManager.showLoadMore && questionsViewManager.questionsFilter.isEmpty {
                HStack {
                    Spacer()
                    
                    Button {
                        questionsViewManager.fetchQuestionsSubject.send(
                            questionsViewManager.fetchQuestionsSubject.value.enablePaging()
                        )
                    } label: {
                        Text("Next page")
                    }.buttonStyle(BorderlessButtonStyle())
                    
                    Spacer()
                }.padding()
            }
        }
        .listRowBackground(Color.stackITDarkGray)
        .onAppear {
            questionsViewManager.fetchQuestionsSubject.send(.questions)
        }
    }
}

struct PostSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        QuestionsSummaryView(questionsViewManager: .init(),
                             answersViewManager: .init())
    }
}
