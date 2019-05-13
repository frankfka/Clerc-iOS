//
//  TransactionDetailView.swift
//  Clerc
//
//  Created by Frank Jia on 2019-05-12.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import UIKit

class TransactionDetailView: UIViewController {

    @IBOutlet weak var storeNameLabel: UILabel!
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    let transaction: Transaction
    
    init(transaction: Transaction) {
        self.transaction = transaction
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        storeNameLabel.text = transaction.storeName ?? "Your Purchase"
        totalAmountLabel.text = TextFormatterService.shared.getCurrencyString(for: transaction.amount)
        if let txnDate = transaction.txnDate {
            dateLabel.text = TextFormatterService.shared.getDateString(for: txnDate, fullMonth: true)
        } else {
            dateLabel.text = ""
        }
        
    }

    @IBAction func emailReceiptPressed(_ sender: UIButton) {
        let viewService = ViewService.shared
        if let txnId = transaction.txnId {
            // Show a loading HUD
            viewService.loadingAnimation(show: true, with: "Sending email")
            StripeService.shared.emailReceipt(txnId: txnId) { success in
                // Dismiss loading
                viewService.loadingAnimation(show: false)
                if success {
                    viewService.showHUD(success: true, message: "Receipt sent")
                } else {
                    viewService.showStandardErrorHUD()
                }
            }
        } else {
            // Transaction somehow does not have an ID
            viewService.showStandardErrorHUD()
        }
    }
    
}
