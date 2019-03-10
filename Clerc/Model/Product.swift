//
//  Product.swift
//  Clerc
//
//  Created by Frank Jia on 2019-03-09.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import Foundation

class Product {
    let name: String
    let cost: Double
    let currency: String
    
    init(name: String, cost: Double, currency: String) {
        self.name = name
        self.cost = cost
        self.currency = currency
    }
    
}
