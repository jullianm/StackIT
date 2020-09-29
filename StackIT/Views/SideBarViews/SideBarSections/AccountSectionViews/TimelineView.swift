//
//  ActivityView.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-09-13.
//

import SwiftUI

struct TimelineView: View {
    @ObservedObject var accountViewManager: AccountViewManager
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
                    ForEach(accountViewManager.timeline, id: \.id) { timelineItem in
                        if let title = timelineItem.title {
                            DisclosureGroup(timelineItem.creationDate + " - " + timelineItem.timelineType) {
                                if let detail = timelineItem.detail {
                                    DisclosureGroup(title) {
                                        HStack {
                                            Image(systemName: "circle.fill")
                                                .renderingMode(.template)
                                                .resizable()
                                                .frame(width: 5, height: 5)
                                                .foregroundColor(Color.blue)
                                            
                                            Text(detail)
                                                .frame(height: 50)
                                                .lineLimit(nil)
                                        }
                                    }
                                } else {
                                    HStack {
                                        Image(systemName: "circle.fill")
                                            .renderingMode(.template)
                                            .resizable()
                                            .frame(width: 5, height: 5)
                                            .foregroundColor(Color.blue)
                                        
                                        Text(title)
                                    }
                                }
                            }
                        } else {
                            Text(timelineItem.creationDate) + Text( " - ") + Text(timelineItem.timelineType)
                        }
                    }
                    .listRowBackground(Color.stackITCode)
                }.id(UUID())
                
                if accountViewManager.loadingSections.contains(.timeline) {
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
        .frame(width: 800, height: 500)
        .padding()
    }
}
