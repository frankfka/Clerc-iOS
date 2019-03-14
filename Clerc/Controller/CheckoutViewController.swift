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
    
    // The following should be initialized at view presentation
    var cost: Double?
    var vendor: Vendor?
    
    // Stripe's class for standard payment flow
    var paymentContext: STPPaymentContext?
    
    // State
    var paymentInProgress: Bool = false {
        didSet {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                if self.paymentInProgress {
                    print("Payment in progress")
                    // Show loading
                    ViewService.loadingAnimation(show: true, with: "Processing Payment")
                    // Disable Pay Now Button
                    self.payNowButton.isUserInteractionEnabled = false
                    self.payNowButton.alpha = 0.2
                }
                else {
                    print("Payment not in progress")
                    // Dismiss loading
                    ViewService.loadingAnimation(show: false, with: nil)
                    // Enable Pay Now button
                    self.payNowButton.isUserInteractionEnabled = true
                    self.payNowButton.alpha = 1
                }
            }, completion: nil)
        }
    }
    
    // UI Elements
    @IBOutlet weak var paymentOptionButton: UIButton!
    @IBOutlet weak var payNowButton: UIButton!
    @IBOutlet weak var totalCostLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check that required properties are satisfied
        if (cost == nil || vendor == nil) {
            ViewService.showHUD(success: false, message: "Something went wrong. Please try again.")
            // Return if something is wrong
            navigationController?.popViewController(animated: true)
        }
        
        // Update total cost label
        totalCostLabel.text = TextFormatterService.getCurrencyString(for: cost!)
        
        // Else continue with setup - this should be in an init() function once we present this modally
        let config = STPPaymentConfiguration.shared()
        config.companyName = vendor!.name
        // Get the current customer and payment context
        let customerContext = STPCustomerContext(keyProvider: StripeService.sharedClient)
        let paymentContext = STPPaymentContext(customerContext: customerContext, configuration: config, theme: .default())
        paymentContext.paymentAmount = StripeService.getStripeCost(for: cost!)
        paymentContext.paymentCurrency = StripeConstants.DEFAULT_CURRENCY // Implement custom currencies when we need to
        // Set the required delegates
        paymentContext.delegate = self
        paymentContext.hostViewController = self
        self.paymentContext = paymentContext
    }
    
    @IBAction func paymentMethodTapped(_ sender: UIButton) {
        self.paymentContext!.presentPaymentMethodsViewController()
    }
    
    @IBAction func payNowTapped(_ sender: Any) {
        // TODO confirmation dialog
        self.paymentInProgress = true
        self.paymentContext!.requestPayment()
    }
    
    //
    // MARK: Stripe Delegate Methods
    //
    
    // Indicates that the Stripe class has failed to load - show error and go back to cart
    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
        print("Error loading payment context \(error)")
        ViewService.showHUD(success: true, message: "Something went wrong. Please try again")
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
            StripeService.sharedClient.completeCharge(paymentResult,
                                                    amount: self.paymentContext!.paymentAmount,
                                                    shippingAddress: self.paymentContext!.shippingAddress,
                                                    shippingMethod: self.paymentContext!.selectedShippingMethod,
                                                    completion: completion)
    }
    
    // Backend finished charge with either a success, fail, or user cancellation
    func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
        paymentInProgress = false
        switch status {
            case .error:
                print("User payment errored: \(error!)")
                ViewService.showHUD(success: false, message: "Something went wrong. Your payment was not processed.")
                return
            case .success:
                // Show confirmation screen
                print("User payment succeeded")
                ViewService.showHUD(success: true, message: "Payment Successful")
                dismiss(animated: true, completion: nil) // TODO present success screen here
                return
            case .userCancellation:
                return // Do nothing
        }
    }
    

}
