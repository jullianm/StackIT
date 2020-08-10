//
//  PostSummaryView.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-07-25.
//

import SwiftUI
import AppKit

struct QuestionsSummaryView: View {
    @StateObject private var viewModel: QuestionsSummaryViewModel
    @State private var keyword: String = ""
    @State private var filter = Filter.votes
    
    init(tags: [String] = [], filter: Filter = .votes) {
        _viewModel = StateObject(wrappedValue: QuestionsSummaryViewModel(tags: tags, filter: filter))
    }

    var body: some View {
        NavigationView {
            ZStack {
                List(viewModel.questionsSummary) { questionSummary in
                    NavigationLink(destination: AnswersView(questionId: questionSummary.questionId)) {
                        QuestionsSummaryRow(questionsSummary: questionSummary)
                    }
                }
                .listStyle(InsetListStyle())
                .frame(width: 430)
                
                if viewModel.questionsSummary.isEmpty {
                    ProgressView()
                }
            }
        }.onAppear {
            viewModel.fetchPosts.send(())
        }
    }
}

struct QuestionsSummaryRow: View {
    var questionsSummary: QuestionsSummary
    
    var body: some View {
        VStack {
            HStack(alignment: .top, spacing: 30) {
                VStack(alignment: .leading) {
                    Text(questionsSummary.title)
                    
                    Text(questionsSummary.tags.joined(separator: ", "))
                        .lineLimit(nil)
                        .foregroundColor(Color.gray)
                        .font(.caption)

                    Spacer()
                    
                    Text(questionsSummary.lastActivityDate)
                        .foregroundColor(Color.gray)
                        .italic()
                        .font(.caption)
                }
                
                Spacer()
                
                VStack(spacing: 20) {
                    ZStack {
                        Rectangle()
                            .foregroundColor(Color("StackITGreen"))
                            .cornerRadius(10.0)
                        VStack {
                            Text(questionsSummary.votes).font(.headline)
                            Text("votes").font(.subheadline)
                        }
                    }.frame(width : 70, height: 50)
                    
                    Text(questionsSummary.answers + " " + "answers").font(.footnote)
                }
            }.padding(.top)
            
            Divider()
            
        }
    }
}

struct PostSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        QuestionsSummaryView(tags: ["Swift"])
    }
}
