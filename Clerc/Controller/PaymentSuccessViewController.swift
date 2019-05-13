//
//  PaymentSuccessViewController.swift
//  Clerc
//
//  Created by Frank Jia on 2019-03-14.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import UIKit

class PaymentSuccessViewController: UIViewController {
    
    // Service
    let viewService = ViewService.shared
    let textFormatterService = TextFormatterService.shared
    let backendService = StripeService.shared
    
    // UI Outlets
    @IBOutlet weak var successMessageLabel: UILabel!
    @IBOutlet weak var storeNameLabel: UILabel!
    @IBOutlet weak var totalCostLabel: UILabel!
    @IBOutlet weak var subtotalCostLabel: UILabel!
    @IBOutlet weak var taxesCostLabel: UILabel!
    @IBOutlet weak var itemsTableView: UITableView!
    @IBOutlet weak var itemsTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var parentScrollView: UIScrollView!
    
    // State
    var items: [Product]?
    var quantities: [Double]?
    var store: Store?
    var costBeforeTaxes: Double = 0 // So we don't have to calculate again
    var taxes: Double = 0
    var txnId: String? // Used later for email receipts

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // NOTE: Not doing any error checking here - nothing is
        // critical - if anything, views just aren't loaded
        initializeUI()
        
    }
    
    private func initializeUI() {
        
        // Initialize labels
        subtotalCostLabel.text = textFormatterService.getCurrencyString(for: costBeforeTaxes)
        taxesCostLabel.text = textFormatterService.getCurrencyString(for: taxes)
        totalCostLabel.text = textFormatterService.getCurrencyString(for: costBeforeTaxes + taxes)
        storeNameLabel.text = store?.name ?? ""
        // Custom success message
        if let customSuccessMsg = store?.successMessage {
            successMessageLabel.text = customSuccessMsg
        }
        
        // Initialize tableview
        itemsTableView.delegate = self
        itemsTableView.dataSource = self
        itemsTableView.allowsSelection = false // Can't select rows
        itemsTableView.register(UINib(nibName: "ProductTableViewCell", bundle: nil), forCellReuseIdentifier: "ProductTableViewCell")
        itemsTableView.reloadData()
        
        // Tableview should not scroll
        viewService.updateTableViewSize(tableView: itemsTableView, tableViewHeightConstraint: itemsTableViewHeight)
        viewService.updateScrollViewSize(for: parentScrollView)
        
    }
    
    // Call backend to email receipt
    @IBAction func emailReceiptButtonPressed(_ sender: UIButton) {
        if let txnId = txnId {
            // Show a loading HUD
            self.viewService.loadingAnimation(show: true, with: "Sending email")
            backendService.emailReceipt(txnId: txnId) { success in
                // Dismiss loading
                self.viewService.loadingAnimation(show: false)
                if success {
                    self.viewService.showHUD(success: true, message: "Receipt sent")
                } else {
                    self.viewService.showStandardErrorHUD()
                }
            }
        } else {
            // Transaction ID somehow null
            self.viewService.showStandardErrorHUD()
        }
    }
    
    // Dismiss when done pressed
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

}

extension PaymentSuccessViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let productCell = tableView.dequeueReusableCell(withIdentifier: "ProductTableViewCell") as! ProductTableViewCell
        // Pass in params
        let product = items?[indexPath.row] ?? Product(id: "", name: "", cost: 0, currency: "", priceUnit: Product.PriceUnit.unit) // Should always exist but we'll have a backup
        let quantity = quantities?[indexPath.row] ?? 0
        productCell.loadUI(for: product, with: quantity)
        return productCell
    }
    
}
