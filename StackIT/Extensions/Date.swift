//
//  Date.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-08-10.
//

import Foundation

extension Date {
    func dateFormatWithSuffix() -> String {
        return "MMMM dd'\(daySuffix())' yyyy"
    }

    private func daySuffix() -> String {
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components(.day, from: self)
        let dayOfMonth = components.day
        switch dayOfMonth {
        case 1, 21, 31:
            return "st"
        case 2, 22:
            return "nd"
        case 3, 23:
            return "rd"
        default:
            return "th"
        }
    }
}
