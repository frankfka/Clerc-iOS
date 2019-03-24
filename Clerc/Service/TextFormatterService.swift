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
    
}
