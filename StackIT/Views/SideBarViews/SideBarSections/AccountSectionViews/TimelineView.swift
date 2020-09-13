//
//  ActivityView.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-09-13.
//

import SwiftUI

struct TimelineView: View {
    @EnvironmentObject var viewManager: ViewManager
    var onCloseTapped: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Timeline").font(.largeTitle).padding(.leading)
                Spacer()
                Button {
                    onCloseTapped()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                }.buttonStyle(BorderlessButtonStyle())
            }.padding(.bottom)
            
            ZStack {
                List {
                    ForEach(viewManager.timeline, id: \.id) { timelineItem in
                        HStack {
                            Image(systemName: "circle.fill")
                                .renderingMode(.template)
                                .resizable()
                                .frame(width: 5, height: 5)
                                .foregroundColor(Color.blue)
                            
                            Text(timelineItem.creationDate) + Text( " - ") + Text(timelineItem.timelineType)
                        }
                    }
                    .listRowBackground(Color.stackITCode)
                }.id(UUID())
                
                if viewManager.loadingSections.contains(.timeline) {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                        Spacer()
                    }
                }
            }
        }
        .frame(width: 500, height: 500)
        .padding()
    }
}
