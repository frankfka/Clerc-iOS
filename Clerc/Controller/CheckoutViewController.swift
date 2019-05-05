//
//  CheckoutViewController.swift
//  Clerc
//
//  Created by Frank Jia on 2019-03-12.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import UIKit
import Stripe
import RealmSwift

class CheckoutViewController: UIViewController, STPPaymentContextDelegate {
    
    // Services
    let textFormatterService = TextFormatterService.shared
    let utilityService = UtilityService.shared
    let firebaseService = FirebaseService.shared
    let viewService = ViewService.shared
    let realm = try! Realm()
    
    // The following should be initialized at view presentation
    var store: Store?
    var items: [Product]?
    var quantities: [Int]?
    
    // Computed state
    var costBeforeTaxes: Double = 0.0
    var costAfterTaxes: Double = 0.0
    var taxes: Double = 0.0
    
    // Stripe's class for standard payment flow
    var paymentContext: STPPaymentContext?
    
    // Loading State
    var isPaymentLoading: Bool = false {
        didSet {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                if self.isPaymentLoading {
                    // Show loading
                    ViewService.shared.loadingAnimation(show: true, with: "Please Wait")
                    // Disable Pay Now Button
                    self.viewService.setButtonState(button: self.payNowButton, enabled: false)
                }
                else {
                    // Dismiss loading
                    ViewService.shared.loadingAnimation(show: false, with: nil)
                    // Enable Pay Now button\
                    self.viewService.setButtonState(button: self.payNowButton, enabled: true)
                }
            }, completion: nil)
        }
    }
    var paymentDone: Bool = false // Used to decide whether we dismiss the entire checkout navigation controller
    
    // UI Elements
    @IBOutlet weak var editPaymentButton: UIButton!
    @IBOutlet weak var payNowButton: UIButton!
    @IBOutlet weak var totalCostLabel: UILabel!
    @IBOutlet weak var subtotalCostLabel: UILabel!
    @IBOutlet weak var taxesCostLabel: UILabel!
    @IBOutlet weak var storeNameLabel: UILabel!
    @IBOutlet weak var paymentMethodLabel: UILabel!
    @IBOutlet weak var parentScrollView: UIScrollView!
    @IBOutlet weak var itemsTableView: UITableView!
    @IBOutlet weak var itemsTableViewHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check that required properties are satisfied
        // Store, current customer must not be nil
        // items, quantities must not be nil & must not be empty & must have equal lengths
        if (store == nil || items == nil || quantities == nil || Customer.current == nil
            || items!.isEmpty || quantities!.isEmpty || items!.count != quantities!.count) {
            ViewService.shared.showStandardErrorHUD()
            // Return if something is wrong
            navigationController?.popViewController(animated: true)
        }
        
        // Initialize
        initializeState()
        initializeUI()
    }
    
    // Called when we come back from success screen
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if paymentDone {
            // We are returning from the payment success view controller
            dismiss(animated: true, completion: nil)
        }
    }
    
    // Initialization of State
    // Sets amounts, loads Stripe
    private func initializeState() {
        
        // Calculate total cost
        costBeforeTaxes = utilityService.getTotalCost(for: items!, with: quantities!)
        taxes = utilityService.getTaxes(for: costBeforeTaxes, with: store!)
        costAfterTaxes = costBeforeTaxes + taxes
        
        // Configure Stripe
        let config = STPPaymentConfiguration.shared()
        config.companyName = store!.name
        // Get the current customer and payment context
        let customerContext = STPCustomerContext(keyProvider: StripeService.shared) // TODO may need to initialize earlier so that payment context is preloaded - can do so in a "SessionService" like on Android
        let paymentContext = STPPaymentContext(customerContext: customerContext, configuration: config, theme: .default())
        // IMPORTANT: Total paid is cost after taxes!
        paymentContext.paymentAmount = StripeService.getStripeCost(for: costAfterTaxes)
        paymentContext.paymentCurrency = StripeConstants.DEFAULT_CURRENCY // Implement custom currencies when we need to
        // Set the required delegates
        paymentContext.delegate = self
        paymentContext.hostViewController = self
        self.paymentContext = paymentContext
        
    }
    // Initialize UI
    private func initializeUI() {
        
        // Disable payment button until payment context loads!
        viewService.setButtonState(button: payNowButton, enabled: false)
        
        // Initialize labels
        subtotalCostLabel.text = textFormatterService.getCurrencyString(for: costBeforeTaxes)
        taxesCostLabel.text = textFormatterService.getCurrencyString(for: taxes)
        totalCostLabel.text = textFormatterService.getCurrencyString(for: costAfterTaxes)
        storeNameLabel.text = store!.name
        
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
    
    // Present Stripe's payment method VC
    @IBAction func editPaymentTapped(_ sender: UIButton) {
        self.paymentContext!.presentPaymentMethodsViewController()
    }
    
    // Called when user confirms payment
    @IBAction func payNowTapped(_ sender: Any) {
        // Ask for confirmation
        ViewService.shared.showConfirmationDialog(title: "Confirm Payment", description: "Confirm your payment of \(TextFormatterService.shared.getCurrencyString(for: costBeforeTaxes)) to \(store!.name)") { (didConfirm) in
            // Submit payment only if they confirmed
            if (didConfirm) {
                self.isPaymentLoading = true
                self.paymentContext!.requestPayment()
            }
        }
    }
    
    //
    // MARK: Stripe Delegate Methods
    //
    
    // Indicates that the Stripe class has failed to load - show error and go back to shopping
    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
        print("Error loading payment context \(error)")
        ViewService.shared.showStandardErrorHUD()
        navigationController?.popViewController(animated: true)
    }
    
    // Called when a user's payment information changes
    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
        // If paymentContext has a saved payment information
        if let paymentOption = paymentContext.selectedPaymentMethod {
            print("Payment context loaded with saved payment method")
            paymentMethodLabel.text = paymentOption.label
            // Payment is loaded, enable pay button
            viewService.setButtonState(button: payNowButton, enabled: true)
        } else {
            // No saved payment information, prompt user to select a payment
            print("Payment context loaded without saved payment method")
            paymentMethodLabel.text = "None"
        }
    }
    
    // User confirms payment - call backend to complete the charge
    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPErrorBlock) {
        // Call our backend to complete the charge
        StripeService.shared.completeCharge(paymentResult, amount: self.paymentContext!.paymentAmount, store: store!) { (success, txnId, error) in
            if success {
                completion(nil) // Give the STP completion a nil value to indicate payment success
                // Write the transaction to firebase
                let currentCustomer = Customer.current! // Must exist - checked in initialization
                self.firebaseService.writeTransaction(from: currentCustomer.firebaseID,
                                                      to: self.store!.id,
                                                      costBeforeTaxes: self.costBeforeTaxes,
                                                      taxes: self.taxes,
                                                      costAfterTaxes: self.costAfterTaxes,
                                                      items: self.items!,
                                                      quantities: self.quantities!,
                                                      txnId: txnId ?? "")
                // Write to local realm database
                let newTxn = Transaction()
                newTxn.txnId = txnId
                newTxn.storeName = self.store!.name
                newTxn.txnDate = Date()
                newTxn.amount = self.costAfterTaxes // No migrations yet, so just log the amount after taxes
                newTxn.currency = StripeConstants.DEFAULT_CURRENCY
                try! self.realm.write {
                    self.realm.add(newTxn)
                }
            } else {
                completion(error)
            }
        }
    }
    
    // Backend finished charge with either a success, fail, or user cancellation
    func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
        isPaymentLoading = false
        switch status {
            case .error:
                print("User payment errored: \(error!)")
                viewService.showStandardErrorHUD()
                return
            case .success:
                // Show confirmation screen
                print("User payment succeeded")
                // Set state and disable payment button
                paymentDone = true
                viewService.setButtonState(button: payNowButton, enabled: false)
                // Show success screen
                performSegue(withIdentifier: "CheckoutToSuccessSegue", sender: self)
                return
            case .userCancellation:
                return // Do nothing
        }
    }

}

// MARK: Tableview Methods
extension CheckoutViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let productCell = tableView.dequeueReusableCell(withIdentifier: "ProductTableViewCell") as! ProductTableViewCell
        // Pass in params
        let product = items?[indexPath.row] ?? Product(id: "", name: "", cost: 0, currency: "") // Should always exist but we'll have a backup
        let quantity = quantities?[indexPath.row] ?? 0
        productCell.loadUI(for: product, with: quantity)
        return productCell
    }
    
}
