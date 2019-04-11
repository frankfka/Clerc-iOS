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
    let stripeId: String
    
    init(id: String, name: String, stripeId: String) {
        self.id = id
        self.name = name
        self.stripeId = stripeId
    }
    
}

// Deals with object equality
extension Store: Equatable {
    static func == (lhs: Store, rhs: Store) -> Bool {
        return lhs.id == rhs.id
    }
}
