//
//  String.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-08-10.
//

import AppKit

extension String {
    func addStyling() -> String {
        return "<html><style>html {font-size: 1.1em;color: white; font-family: -apple-system}</style>" + self
    }
    
    func convertToAttributedText() -> NSAttributedString? {
        let data = Data(utf8)
        let options: [NSAttributedString.DocumentReadingOptionKey : Any] = [.documentType: NSAttributedString.DocumentType.html]
        if let attributedString = try? NSMutableAttributedString(data: data, options: options, documentAttributes: nil) {
            attributedString.addAttributes([.backgroundColor: NSColor(named: "StackITCode")!], range: NSMakeRange(0, attributedString.length))
            return attributedString
        }
        
        return nil
    }
}
