//
//  NewQuestionView.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-10-01.
//

import SwiftUI

struct NewQuestionView: View {
    var onCloseTapped : () -> Void
    
    var body: some View {
        VStack {
            HStack {
                Text("Ask a question").font(.largeTitle).padding(.leading)
                
                Spacer()
                
                Button {
                    onCloseTapped()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                }.buttonStyle(BorderlessButtonStyle())
            }.padding()
            
            Spacer()
            
        }.frame(width: 800, height: 500)
    }
}
