//
//  Int.swift
//  StackIT
//
//  Created by Jullian Mercier on 2020-08-10.
//

import Foundation

extension Int {
    func string() -> String {
        String(self)
    }
    
    func stringDate() -> String {
        let date = Date(timeIntervalSince1970: Double(self))
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        dateFormatter.dateFormat = date.dateFormatWithSuffix()
        return dateFormatter.string(from: date)
    }
    
    func formatNumber() -> String {
        let num = abs(Double(self))
        let sign = (self < 0) ? "-" : ""
        
        switch num {
        case 1_000_000_000...:
            var formatted = num / 1_000_000_000
            formatted = formatted.truncate(places: 1)
            return "\(sign)\(formatted)B"
        case 1_000_000...:
            var formatted = num / 1_000_000
            formatted = formatted.truncate(places: 1)
            return "\(sign)\(formatted)M"
        case 1_000...:
            var formatted = num / 1_000
            formatted = formatted.truncate(places: 1)
            return "\(sign)\(formatted)K"
        case 0...:
            return "\(self)"
        default:
            return "\(sign)\(self)"
        }
    }
}
