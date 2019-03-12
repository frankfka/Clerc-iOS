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
    
    init(id: String, name: String, cost: Double, currency: String) {
        self.id = id
        self.name = name
        self.cost = cost
        self.currency = currency
    }
    
}

// Deals with object equality
extension Product: Equatable {
    static func == (lhs: Product, rhs: Product) -> Bool {
        return lhs.id == rhs.id
    }
}

