//
//  ProfileView.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-09-13.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var imageManager: ImageManager
    @EnvironmentObject var viewManager: ViewManager
    @Environment(\.openURL) private var openURL
    var onCloseTapped: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Profile").font(.largeTitle).padding(.leading)
                Spacer()
                Button {
                    onCloseTapped()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                }.buttonStyle(BorderlessButtonStyle())
            }.padding(.bottom)
            
            HStack {
                if let image = imageManager.image {
                    Image(nsImage: image)
                        .resizable()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 1))
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 1))
                }
                
                VStack(alignment: .leading) {
                    Text(viewManager.user?.displayName ?? .init())
                    Text(viewManager.user?.location ?? .init())
                }
                
                Spacer()
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Reputation")
                    Text(viewManager.user?.reputation.string() ?? .init())
                }
                
                Spacer()
            }
           
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Badges")
                    ForEach(viewManager.user?.badges ?? [], id: \.self) { badge in
                        HStack {
                            Image(systemName: "circle.fill")
                                .renderingMode(.template)
                                .foregroundColor(badge.color)
                            Text(badge.value)
                        }
                    }
                }
                
                Spacer()
            }
            
            HStack {
                Button {
                    openURL(URL(string: viewManager.user?.link ?? .init())!)
                } label: {
                    Text("Edit profile")
                }
                
                Spacer()
            }
            
            Spacer()
        }
        .frame(width: 500, height: 300)
        .padding()
    }
}