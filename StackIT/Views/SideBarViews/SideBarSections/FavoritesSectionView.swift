//
//  FavoritesSectionView.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-10-10.
//

import SwiftUI

struct FavoritesSectionView: View {
    @ObservedObject var questionsViewManager: QuestionsViewManager
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Favorites")
                .foregroundColor(Color.gray)
                .font(.subheadline)
                .padding(.leading)
            
            Divider()
                .background(Color.gray)
                .opacity(0.1)
                .padding(.leading)
            
            HStack {
                let favorites = questionsViewManager.favoritesQuestions.toArray()
  
                Image(systemName: favorites.isEmpty ? "heart": "heart.fill")
                Text(favorites.isEmpty ? "No favorites": favorites.count.string())
            }
            .padding([.leading, .bottom])
            .onTapGesture {
                guard questionsViewManager.favoritesQuestions.toArray().count > 0 else {
                    return
                }
                
                questionsViewManager.fetchQuestionsSubject.send(
                    .questions(subsection: .favorites, nil)
                )
            }
        }.padding([.top])
    }
}
