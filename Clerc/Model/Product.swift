//
//  Product.swift
//  Clerc
//
//  Created by Frank Jia on 2019-03-09.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import Foundation

class Product {
    
    let id: String
    let name: String
    let cost: Double
    let currency: String
    let priceUnit: PriceUnit
    
    init(id: String, name: String, cost: Double, currency: String, priceUnit: PriceUnit) {
        self.id = id
        self.name = name
        self.cost = cost
        self.currency = currency
        self.priceUnit = priceUnit
    }
    
    // Enum for by-weight measurement
    enum PriceUnit: String {
        case lb = "lb"
        case kg = "kg"
        case unit = "unit"
    }
    
}

// Deals with object equality
extension Product: Equatable {
    static func == (lhs: Product, rhs: Product) -> Bool {
        return lhs.id == rhs.id
    }
}

