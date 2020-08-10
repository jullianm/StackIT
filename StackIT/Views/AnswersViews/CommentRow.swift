//
//  CommentRow.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-08-10.
//

import SwiftUI

struct CommentRow: View {
    @ObservedObject var imageManager: ImageManager
    var comment: CommentsSummary
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if let image = imageManager.image {
                    Image(nsImage: image)
                        .resizable()
                        .frame(width: 20, height: 20)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 1))
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 1))
                }
                
                Text(comment.authorName).font(.subheadline)
                Spacer()
            }
            
            NSTextFieldRepresentable(htmlString: comment.body)
            
            Divider()
                .background(Color.gray)
                .opacity(0.1)
                .padding([.bottom, .top])
                
        }.padding(.top)
    }
}
