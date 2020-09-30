//
//  TagSectionView.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-08-10.
//

import SwiftUI

struct TagSectionView: View {
    @ObservedObject var questionsViewManager: QuestionsViewManager
    private let columns = [GridItem(.adaptive(minimum: 80))]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Tags")
                .foregroundColor(Color.gray)
                .font(.subheadline)
                .padding(.leading)
            
            Divider()
                .background(Color.gray)
                .opacity(0.1)
                .padding(.leading)
            
            LazyVGrid(columns: columns) {
                ForEach(questionsViewManager.tags, id: \.id) { tag in
                    ZStack {
                        Rectangle()
                            .foregroundColor(tag.isFavorite ? Color.gray: Color.gray.opacity(0.4))
                            .cornerRadius(10.0)
                            .frame(minWidth: 80, minHeight: 20)
                        
                        Text(tag.name)
                    }
                    .redacted(reason: questionsViewManager.loadingSections.contains(.tags) ? .placeholder: [])
                    .onTapGesture {
                        questionsViewManager.fetchQuestionsSubject.send(
                            .questions(subsection: .tag(tag: tag))
                        )
                    }
                }
            }.padding(.horizontal)
        }
        .padding([.top])
        .onAppear {
            questionsViewManager.fetchTagsSubject.send(.tags)
        }
    }
}

struct TagSectionView_Previews: PreviewProvider {
    static var previews: some View {
        TagSectionView(questionsViewManager: .init())
    }
}
