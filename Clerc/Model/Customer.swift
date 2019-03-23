//
//  Customer.swift
//  Clerc
//
//  Created by Frank Jia on 2019-03-22.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import Foundation

class Customer {
    
    // A current customer object - only one customer should exist
    static var current: Customer?
    
    let firebaseID: String
    let stripeID: String
    var name: String?
    var email: String?
    
    init(firebaseID: String, stripeID: String, name: String?, email: String?) {
        self.firebaseID = firebaseID
        self.stripeID = stripeID
        self.name = name
        self.email = email
    }
    
    // Clears the current customer object
    static func clearCurrent() {
        current = nil
    }
    
}
