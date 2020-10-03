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

            if let test = try? body.text(), test.contains("You are a victim of") {
                print("stop")
            }

            var inP = false
            var currentP = "".addStyling()
            for element in body.children() {
                if element.tag().getName() == "pre", var code = try? element.text() {
                    if inP, let attributedText = convertToAttributedText(htmlString: currentP) {
                        inP = false
                        result.append(.plainText(text: attributedText))
                        currentP = "".addStyling()
                    }

                    result.append(.codeText(text: "Toto\n\(code)\nToto"))
                } else {
                    if let aTag = element.children().first(where: { elt -> Bool in elt.tag().getName() == "a" }), let _ = aTag.children().first(where: { elt -> Bool in elt.tag().getName() == "img" }) {
                        if inP, let attributedText = convertToAttributedText(htmlString: currentP) {
                            inP = false
                            result.append(.plainText(text: attributedText))
                            currentP = "".addStyling()
                        }

                        if let image = extractImage(element: element) {
                            result.append(.image(image: image))
                        }
                    } else if let html = try? element.outerHtml() {
                        inP = true
                        currentP += html
                    }
                    /*if element.children().contains(where: { element -> Bool in element.tag().getName() == "a" || element.tag().getName() == "img" }) {
                        if inP, let attributedText = convertToAttributedText(htmlString: currentP) {
                            inP = false
                            result.append(.plainText(text: attributedText))
                            currentP = "".addStyling()
                        }

                        if let image = extractImage(element: element) {
                            result.append(.image(image: image))
                        }

                    } else if let html = try? element.outerHtml() {
                        inP = true
                        currentP += html
                    }*/
                }
            }

            if inP, let attributedText = convertToAttributedText(htmlString: currentP) {
                inP = false
                result.append(.plainText(text: attributedText))
            }
        }

        return result
    }

    private func extractImage(element: Element) -> ImageData? {
        var finalUrl: URL? = nil
        var legend: NSAttributedString?

        for content in element.children() {
            if content.tag().getName() == "a" {
                if let img = content.children().filter({ element -> Bool in element.tag().getName() == "img" }).first, let src = try? img.attr("src"), let url = URL(string: src) {
                    finalUrl = url
                }
            } else if content.tag().getName() == "sub", let html = try? content.outerHtml() {
                legend = convertToAttributedText(htmlString: html.addStyling())
            } else if content.tag().getName() == "img" {
                if let src = try? content.attr("src"), let url = URL(string: src) {
                    finalUrl = url
                }
            }
        }

        if let url = finalUrl {
            return ImageData(url: url, legend: legend)
        }

        return nil
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
