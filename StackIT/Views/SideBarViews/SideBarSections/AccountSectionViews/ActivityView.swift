//
//  ActivityView.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-09-13.
//

import SwiftUI

struct ActivityView: View {
    @EnvironmentObject var viewManager: ViewManager
    var onCloseTapped: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Activity").font(.largeTitle).padding(.leading)
                Spacer()
                Button {
                    onCloseTapped()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                }.buttonStyle(BorderlessButtonStyle())
            }.padding(.bottom)
            
            Spacer()
        }
        .frame(width: 800, height: 500)
        .padding()
    }
}
