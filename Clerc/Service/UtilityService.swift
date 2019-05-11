//
//  UtilityService.swift
//  Clerc
//
//  Created by Frank Jia on 2019-04-11.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import Foundation
import Alamofire

// Misc functions
class UtilityService {
    
    static let shared = UtilityService()
    
    // Calculates total in cart
    public func getTotalCost(for items:[Product], with quantities:[Double]) -> Double {
        var totalPrice = 0.0
        for index in 0..<items.count {
            totalPrice = totalPrice + items[index].cost * quantities[index]
        }
        return totalPrice
    }
    
    // Calculates taxes
    public func getTaxes(for subtotal: Double, with store: Store) -> Double {
        return subtotal * store.taxRate
    }
    
    // Returns the response JSON from AF failure cases
    public func getErrorResponse(from response: DataResponse<Any>) -> [String : String]? {
        if let data = response.data {
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: String] {
                return json
            }
        }
        return nil
    }
    
}
