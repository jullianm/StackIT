//
//  AnswerDetail.swift
//  StackIT
//
//  Created by Jessy on 26/09/2020.
//

import Foundation

public enum MessageDetail: Hashable {
    case plainText(text: NSAttributedString)
    case codeText(text: String)
    case image(image: ImageData)
}

public struct ImageData: Hashable {
    let url: URL
    let legend: NSAttributedString?
}
