//
//  AppView.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-07-25.
//

import SwiftUI

struct AppView: View {
    @EnvironmentObject var viewManager: ViewManager
    @State private var search: String = .init()
    
    var body: some View {
        HStack {
            SideBarView().frame(minWidth: 250, maxWidth: 250, minHeight: 650, maxHeight: .infinity)
            QuestionsSummaryView().frame(minWidth: 400, maxWidth: 500)
            AnswersView().frame(minWidth: 450, maxWidth: 600)
        }
        .navigationTitle(String.init())
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button {
                    
                } label: {
                    Image(systemName: "arrow.clockwise")
                }

            }
            
            ToolbarItem(placement: .principal) {
                ZStack(alignment: .trailing) {
                    TextField("", text: $search, onCommit: {
                        NSApplication.shared.endEditing()
                        guard !search.isEmpty else { return }
                        self.viewManager.fetchQuestionsSubject.send((.search(keywords: search), false))
                    }).textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Image(systemName: "magnifyingglass")
                        .renderingMode(.template)
                        .foregroundColor(Color.gray.opacity(0.6))
                        .padding()
                }.frame(width: 500, height: 30)
            }
        }
    }
}
