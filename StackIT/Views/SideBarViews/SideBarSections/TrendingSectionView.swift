//
//  TrendingSectionView.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-08-10.
//

import SwiftUI
import enum StackAPI.Trending

struct TrendingSectionView: View {
    @ObservedObject var questionsViewManager: QuestionsViewManager
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Trending")
                .foregroundColor(Color.gray)
                .font(.subheadline)
                .padding(.leading)
            
            Divider()
                .background(Color.gray)
                .opacity(0.1)
                .padding(.leading)
            
            ForEach(Trending.allCases, id: \.self) { trending in
                HStack {
                    Image(systemName: trending.iconName)
                        .renderingMode(.template)
                        .foregroundColor(.yellow)
                    Text(trending.title)
                    Spacer()
                }
                .padding(.leading)
                .padding(.bottom, 5)
                .onTapGesture {
                    self.questionsViewManager.fetchQuestionsSubject.send(
                        .questions(subsection: .trending(trending: trending))
                    )
                }
            }
        }.padding([.top])
    }
}

struct TrendingSectionView_Previews: PreviewProvider {
    static var previews: some View {
        TrendingSectionView(questionsViewManager: .init())
    }
}
