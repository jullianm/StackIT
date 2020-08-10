//
//  Answers.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-07-26.
//

import Foundation

struct Answers: Codable {
    let items: [Answer]
    let hasMore: Bool
}

struct Answer: Codable {
    let owner: Owner
    let isAccepted: Bool
    let score, lastActivityDate: Int
    let lastEditDate: Int?
    let creationDate, answerId, questionId: Int
    let body: String
}

extension Answers {
    static let empty = Answers(items: [], hasMore: false)
}

extension Answer {
    static let placeholder = Answer(owner: Owner.placeholder,
                                    isAccepted: false,
                                    score: 34000,
                                    lastActivityDate: 1590047664,
                                    lastEditDate: 1590047664,
                                    creationDate: 1590047664,
                                    answerId: 46,
                                    questionId: 45,
                                    body: bodyPlaceholder)
    
    private static let bodyPlaceholder: String = {
        return "<p>I prefer to make it without delegates and segues. It can be done with custom init or by setting optional values.</p>\n\n<p><strong>1. Custom init</strong></p>\n\n<pre><code>class ViewControllerA: UIViewController {\n  func openViewControllerB() {\n    let viewController = ViewControllerB(string: \"Blabla\", completionClosure: { success in\n      print(success)\n    })\n    navigationController?.pushViewController(animated: true)\n  }\n}\n\nclass ViewControllerB: UIViewController {\n  private let completionClosure: ((Bool) -&gt; Void)\n  init(string: String, completionClosure: ((Bool) -&gt; Void)) {\n    self.completionClosure = completionClosure\n    super.init(nibName: nil, bundle: nil)\n    title = string\n  }\n\n  func finishWork() {\n    completionClosure()\n  }\n}\n</code></pre>\n\n<p><strong>2. Optional vars</strong></p>\n\n<pre><code>class ViewControllerA: UIViewController {\n  func openViewControllerB() {\n    let viewController = ViewControllerB()\n    viewController.string = \"Blabla\"\n    viewController.completionClosure = { success in\n      print(success)\n    }\n    navigationController?.pushViewController(animated: true)\n  }\n}\n\nclass ViewControllerB: UIViewController {\n  var string: String? {\n    didSet {\n      title = string\n    }\n  }\n  var completionClosure: ((Bool) -&gt; Void)?\n\n  func finishWork() {\n    completionClosure?()\n  }\n}\n</code></pre>\n"
    }()
}

