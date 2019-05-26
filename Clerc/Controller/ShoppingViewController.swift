//
//  ShoppingViewController.swift
//  Clerc
//
//  Created by Frank Jia on 2019-03-10.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import UIKit
import BarcodeScanner
import SwiftEntryKit

class ShoppingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let barcodes = ["BpZl7IZIE4FZqrlM4gmC", "qE3oF36mLnzxwL3aapvi", "lvbviSNt1pQmxQVuHQbk"]
    var scanCount = 0
    
    var scannedProducts: [Product] = []
    var quantities: [Double] = []
    let utilityService = UtilityService.shared
    let textFormatterService = TextFormatterService.shared
    let viewService = ViewService.shared

    // store object (set by HomeViewController)
    var store: Store?
    
    // UI Variables
    @IBOutlet weak var itemsTableView: UITableView!
    @IBOutlet weak var itemsTableHeight: NSLayoutConstraint!
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var subtotalAmountLabel: UILabel!
    @IBOutlet weak var taxesAmountLabel: UILabel!
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var parentScrollView: UIScrollView!
    @IBOutlet weak var checkoutButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // THIS IS IMPORTANT - we force unwrap store everywhere else here
        guard let store = store else {
            // store should always be initialized - show error if this is not the case
            print("No store was passed to this view controller")
            viewService.showStandardErrorHUD()
            dismiss(animated: true, completion: nil)
            return
        }

        // Set title
        navigationBar.title = store.name
        // Set delegates for items table
        itemsTableView.dataSource = self
        itemsTableView.delegate = self
        itemsTableView.register(UINib(nibName: "ProductTableViewCell", bundle: nil), forCellReuseIdentifier: "ProductTableViewCell")
        updateUI()
        
    }
    
    //
    // Updates UI to reflect current state
    //
    private func updateUI() {
        // Update the tableview
        itemsTableView.reloadData()
        viewService.updateTableViewSize(tableView: itemsTableView, tableViewHeightConstraint: itemsTableHeight)
        viewService.updateScrollViewSize(for: parentScrollView)
        
        // Update the total price
        let subtotal = utilityService.getTotalCost(for: scannedProducts, with: quantities)
        let taxes = utilityService.getTaxes(for: subtotal, with: store!)
        totalAmountLabel.text = textFormatterService.getCurrencyString(for: subtotal + taxes)
        subtotalAmountLabel.text = textFormatterService.getCurrencyString(for: subtotal)
        taxesAmountLabel.text = textFormatterService.getCurrencyString(for: taxes)
        
        // Disable/enable the checkout and clear button
        if (scannedProducts.isEmpty) {
            viewService.setButtonState(button: checkoutButton, enabled: false)
            viewService.setButtonState(button: clearButton, enabled: false)
        } else {
            viewService.setButtonState(button: checkoutButton, enabled: true)
            viewService.setButtonState(button: clearButton, enabled: true)
        }
    }
    
    //
    // MARK: Cart methods
    //
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scannedProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let productCell = tableView.dequeueReusableCell(withIdentifier: "ProductTableViewCell") as! ProductTableViewCell
        // Pass in params
        let product = scannedProducts[indexPath.row]
        let quantity = quantities[indexPath.row]
        productCell.loadUI(for: product, with: quantity)
        return productCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Don't keep the row selected
        tableView.deselectRow(at: indexPath, animated: true)
        
        // First define the completion handler
        let onQuantityChange: (Double) -> Void = { (newQuantity) in
            
            if (newQuantity > 0) {
                // Item not deleted, update the quantity
                self.quantities[indexPath.row] = newQuantity
            } else {
                // Item is deleted, remove the scanned product
                self.quantities.remove(at: indexPath.row)
                self.scannedProducts.remove(at: indexPath.row)
            }
            
            // Update views
            self.updateUI()
        }
        
        // Show the proper dialog for the product type
        let product = scannedProducts[indexPath.row]
        if product.priceUnit == .unit {
            viewService.showEditUnitItemView(for: product, with: quantities[indexPath.row], completion: onQuantityChange)
        } else {
            viewService.showEditWeighedItemView(for: product, with: quantities[indexPath.row], completion: onQuantityChange)
        }
    }
    
    // Bottom add item button pressed. Should show a new barcode scanner VC
    @IBAction func addItemButtonPressed(_ sender: UIButton) {
        
        processBarcodeForScreenshots(code: barcodes[scanCount])
        scanCount = scanCount + 1
        
        // Launch barcode view controller
        // Create the VC then present it modally
//        let barcodeScannerVC = viewService.getBarcodeScannerVC(with: "Scan New Item")
//        barcodeScannerVC.codeDelegate = self
//        barcodeScannerVC.dismissalDelegate = self
//        present(barcodeScannerVC, animated: true, completion: nil)
    }
    
    // Clear cart button pressed. Clear all the arrays if confirmed
    @IBAction func clearCartButtonPressed(_ sender: UIButton) {
        viewService.showConfirmationDialog(title: "Clear Cart", description: "Are you sure you want to clear your shopping cart?") { (didConfirm) in
            if didConfirm {
                self.scannedProducts = []
                self.quantities = []
                self.updateUI()
            }
        }
    }
    
    //
    // MARK: Navigation button pressed methods
    //
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        // Show confirmation, and dismiss if confirmed
        viewService.showConfirmationDialog(title: "Exit Store", description: "Are you sure you want to quit shopping?") { (didConfirm) in
            if (didConfirm) {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func checkoutButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "CartToCheckoutSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CartToCheckoutSegue" {
            // Initialize VC with the required fields (cost & store)
            let destinationVC = segue.destination as! CheckoutViewController
            destinationVC.store = store
            destinationVC.items = scannedProducts
            destinationVC.quantities = quantities
        }
    }
    
}

//
// MARK: Barcode Scanner delegates
//
extension ShoppingViewController: BarcodeScannerCodeDelegate, BarcodeScannerDismissalDelegate {
    
    // Function called when code is captured
    func scanner(_ controller: BarcodeScannerViewController, didCaptureCode code: String, type: String) {

        // This barcode can realistically be of any time, so we don't check type here
        print("Barcode Data: \(code) | Type: \(type)")

        // Call firebase to see if this is a valid product
        FirebaseService.shared.getProduct(from: store!.id, for: code) { (product) in
            if let product = product {
                // Dismiss current viewcontroller & do the following
                controller.dismiss(animated: true) {
                    print("Product found: id: \(product.id), name: \(product.name)")

                    if product.priceUnit == .unit {
                        // Unit logic

                        // Add the product to the shopping list, then update the UI
                        if let itemIndex = self.scannedProducts.firstIndex(of: product) {
                            // First determine if the item has already been added - if so, we just increase the quantity
                            self.quantities[itemIndex] = self.quantities[itemIndex] + 1
                            self.viewService.showHUD(success: true, message: "Updated item.")
                        } else {
                            // Else, just add to the scanned products & quantities array
                            self.scannedProducts.append(product)
                            self.quantities.append(1)
                            self.viewService.showHUD(success: true, message: "Added to cart.")
                        }
                        self.updateUI()

                    } else {
                        // Weighed item logic

                        // See if we can find the item within currently scanned items
                        let possibleItemIndex = self.scannedProducts.firstIndex(of: product)
                        // First define the completion handler
                        let onQuantityChange: (Double) -> Void = { (newQuantity) in

                            // Scanned product in cart
                            if let index = possibleItemIndex {
                                // Either update the quantity, or remove the product
                                if (newQuantity > 0) {
                                    // Item not deleted, update the quantity
                                    self.quantities[index] = newQuantity
                                } else {
                                    // Item is deleted, remove the scanned product
                                    self.quantities.remove(at: index)
                                    self.scannedProducts.remove(at: index)
                                }
                            }
                            // Scanned product not in cart
                            else {
                                // Add to cart
                                if (newQuantity > 0) {
                                    self.scannedProducts.append(product)
                                    self.quantities.append(newQuantity)
                                }
                                // Do nothing if 0 is entered as a quantity or user presses delete
                            }

                            // Update views
                            self.updateUI()
                        }

                        // Logic for actually showing the view
                        var currentQuantity: Double?
                        if let index = possibleItemIndex {
                            currentQuantity = self.quantities[index]
                        }
                        self.viewService.showEditWeighedItemView(for: product, with: currentQuantity, completion: onQuantityChange)
                    }

                }
            } else {
                print("Could not find item barcode in Firebase")
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    controller.resetWithError(message: "No item found. Please try again.")
                }
            }
        }
    }

    // Called when user clicks "Cancel" on the barcode scanning view controller
    func scannerDidDismiss(_ controller: BarcodeScannerViewController) {
        // Dismiss the view controller
        controller.dismiss(animated: true, completion: nil)
    }

}

// Extension for screenshots
extension ShoppingViewController {
    
    private func processBarcodeForScreenshots(code: String) {
        // Call firebase to see if this is a valid product
        FirebaseService.shared.getProduct(from: store!.id, for: code) { (product) in
            if let product = product {
                
                if product.priceUnit == .unit {
                    // Unit logic
                    
                    // Add the product to the shopping list, then update the UI
                    if let itemIndex = self.scannedProducts.firstIndex(of: product) {
                        // First determine if the item has already been added - if so, we just increase the quantity
                        self.quantities[itemIndex] = self.quantities[itemIndex] + 1
                        self.viewService.showHUD(success: true, message: "Updated item.")
                    } else {
                        // Else, just add to the scanned products & quantities array
                        self.scannedProducts.append(product)
                        self.quantities.append(1)
                        self.viewService.showHUD(success: true, message: "Added to cart.")
                    }
                    self.updateUI()
                    
                } else {
                    // Weighed item logic
                    
                    // See if we can find the item within currently scanned items
                    let possibleItemIndex = self.scannedProducts.firstIndex(of: product)
                    // First define the completion handler
                    let onQuantityChange: (Double) -> Void = { (newQuantity) in
                        
                        // Scanned product in cart
                        if let index = possibleItemIndex {
                            // Either update the quantity, or remove the product
                            if (newQuantity > 0) {
                                // Item not deleted, update the quantity
                                self.quantities[index] = newQuantity
                            } else {
                                // Item is deleted, remove the scanned product
                                self.quantities.remove(at: index)
                                self.scannedProducts.remove(at: index)
                            }
                        }
                            // Scanned product not in cart
                        else {
                            // Add to cart
                            if (newQuantity > 0) {
                                self.scannedProducts.append(product)
                                self.quantities.append(newQuantity)
                            }
                            // Do nothing if 0 is entered as a quantity or user presses delete
                        }
                        
                        // Update views
                        self.updateUI()
                    }
                    
                    // Logic for actually showing the view
                    var currentQuantity: Double?
                    if let index = possibleItemIndex {
                        currentQuantity = self.quantities[index]
                    }
                    self.viewService.showEditWeighedItemView(for: product, with: currentQuantity, completion: onQuantityChange)
                }
            }
        }
    }
    
}
