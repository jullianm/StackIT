//
//  NS.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-08-10.
//

import AppKit

extension NSTableView {
    open override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        
        backgroundColor = .clear
        enclosingScrollView?.drawsBackground = false
    }
}

extension NSApplication {
    func endEditing() {
        sendAction(#selector(NSResponder.resignFirstResponder), to: nil, from: nil)
    }
}
