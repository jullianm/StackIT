//
//  Webview.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-07-28.
//

import AppKit
import SwiftUI

struct NSTextFieldRepresentable: NSViewRepresentable {
    let htmlString: String
    let backgroundColor: NSColor
    private let textField = NSTextField()
    
    init(htmlString: String, backgroundColor: NSColor = NSColor(named: "StackITCode")!) {
        self.htmlString = htmlString
        self.backgroundColor = backgroundColor
    }
    
    func makeNSView(context: Context) -> NSTextField {
        makeTextField()
    }
        
    func updateNSView(_ nsView: NSTextField, context: Context) {
        setAttributedString(textField: nsView)
    }
}

extension NSTextFieldRepresentable {
    private func makeTextField() -> NSTextField {
        textField.wantsLayer = true
        textField.layer?.borderWidth = 4
        textField.layer?.borderColor = NSColor(named: "StackITCode")!.cgColor
        textField.backgroundColor = backgroundColor
        textField.drawsBackground = true
        textField.isEditable = false
        textField.isSelectable = false
        textField.lineBreakMode = .byWordWrapping
        textField.maximumNumberOfLines = 0
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textField.setContentCompressionResistancePriority(.required, for: .vertical)
        
        setAttributedString(textField: textField)

        return textField
    }
    
    private func setAttributedString(textField: NSTextField) {
        DispatchQueue.main.async {
            let data = Data(htmlString.utf8)
            let options: [NSAttributedString.DocumentReadingOptionKey : Any] = [
                .documentType: NSAttributedString.DocumentType.html,
            ]
            if let attributedString = try? NSMutableAttributedString(data: data,
                                                              options: options,
                                                              documentAttributes: nil) {
                attributedString.addAttributes([.backgroundColor: NSColor(named: "StackITCode")!,
                                                ],
                                               range: NSMakeRange(0, attributedString.length))
                textField.attributedStringValue = attributedString
            }
        }
    }
}
