//
//  String.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-08-10.
//

import Foundation

extension String {
    func addStyling() -> String {
        return "<html><style>html {font-size: 1em;color: white}</style>" + self
    }
}
