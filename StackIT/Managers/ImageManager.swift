//
//  ImageManager.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-08-03.
//

import Combine
import SwiftUI

class ImageManager: ObservableObject {
    @Published var image: NSImage?
    private var subscriptions = Set<AnyCancellable>()
    
    init(_ string: String) {
        fetchImage(from: string)
    }
    
    private func fetchImage(from string: String) {
        guard !string.isEmpty, let url = URL(string: string) else {
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .map(NSImage.init(data:))
            .replaceError(with: nil)
            .assign(to: \.image, on: self)
            .store(in: &subscriptions)
    }
}
