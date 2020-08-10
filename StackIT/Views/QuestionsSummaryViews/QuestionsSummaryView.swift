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

    var body: some View {
        VStack {
            filterView
            
            Divider()
                .background(Color.gray)
                .opacity(0.1)
                .padding([.leading, .bottom])
            
            List {
                ScrollViewReader { scrollView in
                    ForEach(viewManager.questionsSummary, id: \.id) { questionSummary in
                        QuestionSummaryRow(questionSummary: questionSummary)
                            .redacted(reason: viewManager.loadingSections.contains(.questions) ? .placeholder: [])
                            .onTapGesture {
                                viewManager.fetchAnswersSubject.send((.answers(questionId: questionSummary.questionId), false))
                                scrollView.scrollTo(0)
                            }
                    }
                }
                
                if viewManager.showLoadMore && viewManager.questionsFilter.isEmpty {
                    HStack {
                        Spacer()
                        Button {
                            viewManager.fetchQuestionsSubject.send((viewManager.fetchQuestionsSubject.value.section,
                                                                    isPagingEnabled: true))
                        } label: {
                            Text("Next page")
                        }.buttonStyle(BorderlessButtonStyle())
                        Spacer()
                    }.padding()
                }
            }
            
        }.padding(.top)
        .background(Color.stackITDarkGray)
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
}

struct PostSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        QuestionsSummaryView(viewManager: .init())
    }
}
