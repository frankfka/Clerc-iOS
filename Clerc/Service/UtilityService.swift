//
//  UtilityService.swift
//  Clerc
//
//  Created by Frank Jia on 2019-04-11.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import Foundation

// Misc functions
class UtilityService {
    
    static let shared = UtilityService()
    
    // Calculates total in cart
    public func getTotalCost(for items:[Product], with quantities:[Int]) -> Double {
        var totalPrice = 0.0
        for index in 0..<items.count {
            totalPrice = totalPrice + items[index].cost * Double(quantities[index])
        }
        return totalPrice
    }
    
}
