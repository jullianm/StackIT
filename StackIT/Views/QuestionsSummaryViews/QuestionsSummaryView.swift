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
    @State private var search: String = .init()
    @State private var isActive = true

    var body: some View {
        NavigationView {
            listView.frame(minWidth: 400, maxWidth: 500)
        }.navigationTitle(" ")
    }
}

extension QuestionsSummaryView {
    var filterView: some View {
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
                }.padding()
            }
        }
    }
    
    var listView: some View {
        List {
            VStack {
                filterView
                
                Divider()
                    .background(Color.gray)
                    .opacity(0.1)
                    .padding([.leading, .bottom])
                
                ForEach(viewManager.questionsSummary, id: \.id) { questionSummary in
                    NavigationLink(destination: AnswersView(), isActive: $isActive) {
                        QuestionSummaryRow(questionSummary: questionSummary, isSelected: questionSummary.isSelected)
                            .redacted(reason: viewManager.loadingSections.contains(.questions) ? .placeholder: [])
                            .onTapGesture {
                                viewManager.fetchAnswersSubject.send(.answers(question: questionSummary, .active))
                            }
                    }
                }
            }.padding(.top)
            
            if viewManager.showLoadMore && viewManager.questionsFilter.isEmpty {
                HStack {
                    Spacer()
                    Button {
                        viewManager.fetchQuestionsSubject.send(viewManager.fetchQuestionsSubject.value.updatePaging())
                    } label: {
                        Text("Next page").foregroundColor(Color.white)
                    }.buttonStyle(BorderlessButtonStyle())
                    Spacer()
                }.padding()
            }
        }.listRowBackground(Color.stackITDarkGray)
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
