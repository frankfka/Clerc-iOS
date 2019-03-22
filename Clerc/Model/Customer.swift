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
    static var currentCustomer: Customer?
    
    let firebaseId: String
    let stripeId: String
    var name: String?
    var email: String?
    
    init(firebaseId: String, stripeId: String, name: String?, email: String?) {
        self.firebaseId = firebaseId
        self.stripeId = stripeId
        self.name = name
        self.email = email
    }
    
    static func clearCurrentCustomer() {
        currentCustomer = nil
    }
    
}
