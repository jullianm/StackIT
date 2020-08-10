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
            HStack(alignment: .top, spacing: 30) {
                VStack(alignment: .leading) {
                    Text(questionSummary.title)
                    
                    Text(questionSummary.tags.joined(separator: ", "))
                        .foregroundColor(Color.gray)
                        .font(.caption)
                    
                    Spacer()
                    
                    Text(questionSummary.lastActivityDate)
                        .foregroundColor(Color.gray)
                        .italic()
                        .font(.caption)
                }
                
                Spacer()
                
                VStack(alignment:.leading, spacing: 7) {
                    ZStack {
                        Rectangle()
                            .foregroundColor(Color("StackITGreen"))
                            .cornerRadius(10.0)
                        VStack {
                            Text(questionSummary.votes).font(.headline)
                            Text("votes").font(.subheadline)
                        }
                    }.frame(width : 70, height: 50)
                    .padding(.bottom, 5)
                    
                    HStack(spacing: 8.5) {
                        Image(systemName: "text.bubble.fill")
                        Text(questionSummary.answers)
                    }
                    
                    HStack(spacing: 5) {
                        Image(systemName: "eye.fill")
                        Text(questionSummary.views)
                    }
                }
            }
            
            Divider()
        }
    }
}
