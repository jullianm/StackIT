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

    init(_ url: URL) {
        fetchImage(from: url)
    }

    init(_ string: String) {
        fetchString(from: string)
    }

    private func fetchString(from string: String) {
        guard !string.isEmpty, let url = URL(string: string) else {
            return
        }

        fetchImage(from: url)
    }
    
    private func fetchImage(from url: URL) {

        
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .map(NSImage.init(data:))
            .replaceError(with: nil)
            .receive(on: RunLoop.main)
            .assign(to: \.image, on: self)
            .store(in: &subscriptions)
    }
}
