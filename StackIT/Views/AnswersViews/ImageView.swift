//
//  ImageView.swift
//  StackIT
//
//  Created by Jessy on 29/09/2020.
//

import SwiftUI

struct ImageView: View {
    @ObservedObject var imageManager: ImageManager
    let legend: NSAttributedString?
    
    var body: some View {
        VStack {
            if let image = imageManager.image {
                HStack {
                    Spacer()
                    Image(nsImage: image).resizable().aspectRatio(contentMode: .fit)
                    Spacer()
                }
            }

            if let legend = legend {
                NSTextFieldRepresentable(attributedString: legend)
            }
        }.padding([.leading, .trailing])
    }
}
