//
//  TextFormatterService.swift
//  Clerc
//
//  Created by Frank Jia on 2019-03-10.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import Foundation

class TextFormatterService {
    
    static let shared = TextFormatterService()
    
    // Returns a string formatted with $ sign and 2 decimal places
    func getCurrencyString(for amount: Double) -> String {
        return "$" + String(format: "%.2f", amount)
    }
    
    // Returns a formatted date string
    func getDateString(for date: Date, fullMonth: Bool) -> String {
        let dateFormatter = DateFormatter()
        if (fullMonth) {
            dateFormatter.dateFormat = "MMMM dd, yyyy"
        } else {
            dateFormatter.dateFormat = "MMM dd, yyyy"
        }
        return dateFormatter.string(from: date)
    }
    
}
