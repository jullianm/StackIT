//
//  MessageExtractor.swift
//  StackIT
//
//  Created by Jessy on 26/09/2020.
//

import AppKit
import SwiftSoup

public class MessageExtractor {

    public static let sharedInstance = MessageExtractor()

    private init() { }

    public func parse(html: String) -> [MessageDetail] {
        guard let doc = getDocument(html: html) else {
            return []
        }
        
        var result: [MessageDetail] = []

        if let body = doc.body() {
            var inP = false
            var currentP = "".addStyling()
            for element in body.children() {
                if element.tag().getName() == "pre", var code = try? element.text() {
                    if inP, let attributedText = convertToAttributedText(htmlString: currentP) {
                        inP = false
                        result.append(.plainText(text: attributedText))
                        currentP = "".addStyling()
                    }

                    // fix a wrong height in Text 
                    code.append("\n")

                    result.append(.codeText(text: code))
                } else if let html = try? element.outerHtml() {
                    inP = true
                    currentP += html
                }
            }

            if inP, let attributedText = convertToAttributedText(htmlString: currentP) {
                inP = false
                result.append(.plainText(text: attributedText))
            }
        }

        return result
    }

    private func getDocument(html: String) -> Document? {
        do {
           let doc: Document = try SwiftSoup.parse(html)
           return doc
        } catch Exception.Error(let type, let message) {
            print(message)
            return nil
        } catch {
            print("error")
            return nil
        }
    }

    private func convertToAttributedText(htmlString: String) -> NSAttributedString? {
        let data = Data(htmlString.utf8)
        let options: [NSAttributedString.DocumentReadingOptionKey : Any] = [.documentType: NSAttributedString.DocumentType.html]
        if let attributedString = try? NSMutableAttributedString(data: data, options: options, documentAttributes: nil) {
            attributedString.addAttributes([.backgroundColor: NSColor(named: "StackITCode")!], range: NSMakeRange(0, attributedString.length))
            return attributedString
        }

        return nil
    }
}
