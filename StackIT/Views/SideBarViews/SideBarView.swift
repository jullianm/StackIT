//
//  SideBarView.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-08-06.
//

import SwiftUI

struct SideBarView: View {
    @EnvironmentObject var viewManager: ViewManager
    @State private var isActive = true
    @State private var search: String = .init()
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                AccountSectionView()
                TrendingSectionView()
                TagSectionView()
            }
            .padding(.top, 5)
            .frame(minWidth: 250, maxWidth: 250, minHeight: 650, maxHeight: .infinity)
            .onAppear {
                viewManager.fetchTagsSubject.send(.tags)
            }
            
            QuestionsSummaryView()
            
            AnswersView()
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
                        self.viewManager.fetchQuestionsSubject.send(
                            .questions(subsection: .search(keywords: search))
                        )
                        
                    }).textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Image(systemName: "magnifyingglass")
                        .renderingMode(.template)
                        .foregroundColor(Color.gray.opacity(0.6))
                        .padding()
                }.frame(width: 500, height: 30)
            }
        }
    }
    
    private func resetAll() {
        viewManager.resetAllSubject.send()
        search = .init()
    }
}

struct SideBarView_Previews: PreviewProvider {
    static var previews: some View {
        SideBarView()
    }
}
