//
//  PostSummaryView.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-07-25.
//

import SwiftUI
import AppKit

struct QuestionsSummaryView: View {
    @EnvironmentObject var viewManager: ViewManager
    @State private var isActive = true
    @State private var selectedIndex: UUID?

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
                            viewManager.updateQuestionsFilter(questionFilter)
                        }) {
                            Image(systemName: viewManager.questionsFilter.contains(questionFilter) ? "checkmark.square": "square")
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
            ForEach(viewManager.questionsSummary, id: \.id) { questionSummary in
                QuestionSummaryRow(questionSummary: questionSummary)
                    .background(selectedIndex == questionSummary.id ? Color.white.opacity(0.3): Color.clear)
                    .onTapGesture {
                        selectedIndex = questionSummary.id
                        viewManager.fetchAnswersSubject.send(.answers(question: questionSummary, .active))
                    }
            }.redacted(reason: viewManager.loadingSections.contains(.questions) ? .placeholder: [])
            
            if viewManager.showLoadMore && viewManager.questionsFilter.isEmpty {
                HStack {
                    Spacer()
                    
                    Button {
                        viewManager.fetchQuestionsSubject.send(viewManager.fetchQuestionsSubject.value.enablePaging())
                    } label: {
                        Text("Next page")
                    }.buttonStyle(BorderlessButtonStyle())
                    
                    Spacer()
                }.padding()
            }
        }
        .listRowBackground(Color.stackITDarkGray)
        .onAppear {
            viewManager.fetchQuestionsSubject.send(.questions)
        }
    }
}

struct PostSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        QuestionsSummaryView(viewManager: .init())
    }
}
