//
//  TransactionTableViewCell.swift
//  Clerc
//
//  Created by Frank Jia on 2019-04-18.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import UIKit

class TransactionTableViewCell: UITableViewCell {

    @IBOutlet weak var storeNameLabel: UILabel!
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func loadUI(for transaction: Transaction) {
        
        storeNameLabel.text = transaction.storeName
        totalAmountLabel.text = TextFormatterService.shared.getCurrencyString(for: transaction.amount)
        // Note: each transaction should always have a date
        dateLabel.text = TextFormatterService.shared.getDateString(for: transaction.txnDate!, fullMonth: false)
        
    }

}
