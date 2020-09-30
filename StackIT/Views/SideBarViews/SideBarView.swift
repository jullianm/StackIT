//
//  SideBarView.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-08-06.
//

import SwiftUI

struct SideBarView: View {
    /// Managers
    @ObservedObject var questionsViewManager = QuestionsViewManager()
    private let answersViewManager = AnswersViewManager()
    private let accountViewManager = AccountViewManager()
    
    @State private var isActive = true
    @State private var search: String = .init()
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                AccountSectionView(accountViewManager: accountViewManager)
                TrendingSectionView(questionsViewManager: questionsViewManager)
                TagSectionView(questionsViewManager: questionsViewManager)
            }
            .padding(.top, 5)
            .frame(minWidth: 250, maxWidth: 250, minHeight: 650, maxHeight: .infinity)
            
            QuestionsSummaryView(questionsViewManager: questionsViewManager,
                                 answersViewManager: answersViewManager)
            
            AnswersView(answersViewManager: answersViewManager)
        }
        .listStyle(SidebarListStyle())
        .navigationTitle(String.init())
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button {
                    resetAll()
                } label: {
                    Image(systemName: "arrow.2.circlepath")
                }
            }
            
            ToolbarItem(placement: .principal) {
                ZStack(alignment: .trailing) {
                    TextField("", text: $search, onEditingChanged: { text in
                    }, onCommit: {
                        
                        NSApplication.shared.endEditing()
                        guard !search.isEmpty else { return }
                        self.questionsViewManager.fetchQuestionsSubject.send(
                            .questions(subsection: .search(keywords: search))
                        )
                        
                    }).textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Image(systemName: "magnifyingglass")
                        .renderingMode(.template)
                        .foregroundColor(Color.gray.opacity(0.6))
                        .padding()
                }.frame(width: 500, height: 30)
            }
        }.onOpenURL { url in
            accountViewManager.authenticationSubject.send(.authentication(action: .signIn(url: url)))
        }
    }
    
    private func resetAll() {
        questionsViewManager.resetSubject.send()
        answersViewManager.resetSubject.send()
        search = .init()
    }
}

struct SideBarView_Previews: PreviewProvider {
    static var previews: some View {
        SideBarView()
    }
}
