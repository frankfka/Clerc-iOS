//
//  Store.swift
//  Clerc
//
//  Created by Frank Jia on 2019-03-09.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import Foundation

class Store {
    
    let id: String
    let name: String
    let taxRate: Double
    let successMessage: String?
    
    init(id: String, name: String, taxRate: Double = 0, successMessage: String? = nil) {
        self.id = id
        self.name = name
        self.taxRate = taxRate
        self.successMessage = successMessage
    }
    
}

// Deals with object equality
extension Store: Equatable {
    static func == (lhs: Store, rhs: Store) -> Bool {
        return lhs.id == rhs.id
    }
}
