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

    // Returns a rounded number in string form to display
    func getRoundedNumberString(number: Double, maxFractionDigits: Int) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = maxFractionDigits
        return numberFormatter.string(from: NSNumber(value: number))!
    }

    // Returns the price unit label in string form to display
    func getPriceUnitLabel(_ priceUnit: Product.PriceUnit) -> String {
        switch priceUnit {
            case .lb:
                return "/lb"
            case .kg:
                return "/kg"
            case .unit:
                return " ea." // Leading space
        }
    }
    
}
