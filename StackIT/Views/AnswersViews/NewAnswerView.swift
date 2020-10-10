//
//  NewAnswerView.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-10-10.
//

import SwiftUI

struct NewAnswerView: View {
    var onCloseTapped : () -> Void
    
    var body: some View {
        VStack {
            HStack {
                Text("Write an answer").font(.largeTitle).padding(.leading)
                
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
