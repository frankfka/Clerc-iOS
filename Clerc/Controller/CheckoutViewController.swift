//
//  CheckoutViewController.swift
//  Clerc
//
//  Created by Frank Jia on 2019-03-12.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import UIKit
import Stripe


class CheckoutViewController: UIViewController, STPPaymentContextDelegate {
    
    var cost: Double = 0.0
    let utilityService = UtilityService.shared
    let firebaseService = FirebaseService.shared
    
    // The following should be initialized at view presentation
    var store: Store?
    var items: [Product]?
    var quantities: [Int]?
    
    // Stripe's class for standard payment flow
    var paymentContext: STPPaymentContext?
    
    // State
    var paymentInProgress: Bool = false {
        didSet {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                if self.paymentInProgress {
                    print("Payment in progress")
                    // Show loading
                    ViewService.shared.loadingAnimation(show: true, with: "Processing Payment")
                    // Disable Pay Now Button
                    self.paymentButtonEnabled(false)
                }
                else {
                    print("Payment not in progress")
                    // Dismiss loading
                    ViewService.shared.loadingAnimation(show: false, with: nil)
                    // Enable Pay Now button
                    self.paymentButtonEnabled(true)
                }
            }, completion: nil)
        }
    }
    var paymentDone: Bool = false // Used to decide whether we dismiss the entire checkout navigation controller
    
    // UI Elements
    @IBOutlet weak var paymentOptionButton: UIButton!
    @IBOutlet weak var payNowButton: UIButton!
    @IBOutlet weak var totalCostLabel: UILabel!
    @IBOutlet weak var storeNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check that required properties are satisfied
        if (store == nil || items == nil || quantities == nil
            || items!.isEmpty || quantities!.isEmpty || items!.count != quantities!.count) {
            ViewService.shared.showStandardErrorHUD()
            // Return if something is wrong
            navigationController?.popViewController(animated: true)
        }
        
        // Calculate total cost
        cost = utilityService.getTotalCost(for: items!, with: quantities!)
        
        // Initialize labels
        totalCostLabel.text = TextFormatterService.shared.getCurrencyString(for: cost)
        storeNameLabel.text = store!.name
        
        // Else continue with setup - this should be in an init() function once we present this modally
        let config = STPPaymentConfiguration.shared()
        config.companyName = store!.name
        // Get the current customer and payment context
        let customerContext = STPCustomerContext(keyProvider: StripeService.shared) // TODO may need to initialize earlier so that payment context is preloaded
        let paymentContext = STPPaymentContext(customerContext: customerContext, configuration: config, theme: .default())
        paymentContext.paymentAmount = StripeService.getStripeCost(for: cost)
        paymentContext.paymentCurrency = StripeConstants.DEFAULT_CURRENCY // Implement custom currencies when we need to
        // Set the required delegates
        paymentContext.delegate = self
        paymentContext.hostViewController = self
        self.paymentContext = paymentContext
    }
    
    // Helper function to enable/disable payment button
    private func paymentButtonEnabled(_ enabled: Bool) {
        if enabled {
            payNowButton.isUserInteractionEnabled = true
            payNowButton.alpha = 1
        } else {
            payNowButton.isUserInteractionEnabled = false
            payNowButton.alpha = 0.2
        }
    }
    
    // Called when we come back from success screen
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if paymentDone {
            // We are returning from the payment success view controller
            dismiss(animated: true, completion: nil)
        }
    }
    
    // Present Stripe's payment method VC
    @IBAction func paymentMethodTapped(_ sender: UIButton) {
        self.paymentContext!.presentPaymentMethodsViewController()
    }
    
    // Called when user confirms payment
    @IBAction func payNowTapped(_ sender: Any) {
        // Ask for confirmation
        ViewService.shared.showConfirmationDialog(title: "Confirm Payment", description: "Confirm your payment of \(TextFormatterService.shared.getCurrencyString(for: cost)) to \(store!.name)") { (didConfirm) in
            // Submit payment only if they confirmed
            if (didConfirm) {
                self.paymentInProgress = true
                self.paymentContext!.requestPayment()
            }
        }
    }
    
    //
    // MARK: Stripe Delegate Methods
    //
    
    // Indicates that the Stripe class has failed to load - show error and go back to cart
    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
        print("Error loading payment context \(error)")
        ViewService.shared.showStandardErrorHUD()
        navigationController?.popViewController(animated: true)
    }
    
    // Called when a user's payment information changes
    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
        // Show "Loading"
        print("Loading Payment Context")
        paymentOptionButton.setTitle("Loading", for: .normal)
        // If paymentContext has a saved payment information
        if let paymentOption = paymentContext.selectedPaymentMethod {
            print("Payment context loaded with saved payment method")
            paymentOptionButton.setTitle(paymentOption.label, for: .normal)
        } else {
            // No saved payment information, prompt user to select a payment
            print("Payment context loaded without saved payment method")
            paymentOptionButton.setTitle("Select Payment", for: .normal)
        }
    }
    
    // User confirms payment - call backend to complete the charge
    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPErrorBlock) {
        StripeService.shared.completeCharge(paymentResult, amount: self.paymentContext!.paymentAmount, store: store!) { (success, txnId, error) in
            if success {
                completion(nil) // Give the STP completion a nil value to indicate payment success
                // Write the transaction to firebase
                let currentCustomer = Customer.current // TODO: Check that this exists?
                self.firebaseService.writeTransaction(from: currentCustomer?.firebaseID ?? "",
                                                      to: self.store!.id,
                                                      items: self.items!,
                                                      quantities: self.quantities!,
                                                      txnId: txnId ?? "")
            } else {
                completion(error)
            }
        }
    }
    
    // Backend finished charge with either a success, fail, or user cancellation
    func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
        paymentInProgress = false
        switch status {
            case .error:
                print("User payment errored: \(error!)")
                ViewService.shared.showStandardErrorHUD()
                return
            case .success:
                // Show confirmation screen
                print("User payment succeeded")
                // Set state and disable payment button
                paymentDone = true
                paymentButtonEnabled(false)
                // Show success screen
                performSegue(withIdentifier: "CheckoutToSuccessSegue", sender: self)
                return
            case .userCancellation:
                return // Do nothing
        }
    }
    

}
