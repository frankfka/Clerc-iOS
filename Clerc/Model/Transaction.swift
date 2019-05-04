//
//  Transaction.swift
//  Clerc
//
//  Created by Frank Jia on 2019-04-18.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import Foundation
import RealmSwift

class Transaction: Object {
    
    @objc dynamic var txnId: String?
    @objc dynamic var storeName: String?
    @objc dynamic var txnDate: Date?
    @objc dynamic var amount: Double = 0 // AFTER taxes
    @objc dynamic var currency: String?
    
}
