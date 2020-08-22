//
//  QuestionSummaryRow.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-08-10.
//

import SwiftUI

struct QuestionSummaryRow: View {
    var questionSummary: QuestionsSummary
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text(questionSummary.title)
                    
                    Text(questionSummary.tags.joined(separator: ", "))
                        .foregroundColor(Color.gray)
                        .font(.caption)
                        .opacity(questionSummary.isNoResultFound ? 0: 1)
                    
                    Spacer()
                    
                    Text(questionSummary.lastActivityDate)
                        .foregroundColor(Color.gray)
                        .italic()
                        .font(.caption)
                        .opacity(questionSummary.isNoResultFound ? 0: 1)
                }
                
                Spacer()
                
                VStack(alignment:.leading, spacing: 7) {
                    ZStack {
                        Rectangle()
                            .foregroundColor(Color.blue.opacity(0.5))
                            .cornerRadius(10.0)
                        VStack {
                            Text(questionSummary.score).font(.headline)
                            Text("votes").font(.subheadline)
                        }
                    }
                    .frame(width : 70, height: 50)
                    .padding(.bottom, 5)
                    
                    HStack(spacing: 8.5) {
                        Image(systemName: "text.bubble.fill")
                        Text(questionSummary.answers)
                    }
                    
                    HStack(spacing: 5) {
                        Image(systemName: "eye.fill")
                        Text(questionSummary.views)
                    }
                }.opacity(questionSummary.isNoResultFound ? 0: 1)
            }.padding(.top, 10)
            
            Divider().opacity(questionSummary.isNoResultFound ? 0: 1)
        }.contentShape(Rectangle())
    }
}

struct QuestionsSummaryRow_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
