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
    
    var scannedProducts: [Product] = []
    var quantities: [Int] = []

    // Vendor object (set by HomeViewController)
    var vendor: Vendor?
    
    // UI Variables
    @IBOutlet weak var itemsTableView: UITableView!
    @IBOutlet weak var itemsTableHeight: NSLayoutConstraint!
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var parentScrollView: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // THIS IS IMPORTANT - we force unwrap vendor everywhere else here
        if vendor != nil {
            // Set title
            navigationBar.title = vendor?.name
            // Set delegates for items table
            itemsTableView.dataSource = self
            itemsTableView.delegate = self
            itemsTableView.register(UINib(nibName: "ShoppingItemTableViewCell", bundle: nil), forCellReuseIdentifier: "ShoppingItemTableViewCell")
            updateUI()
        } else {
            // Vendor should always be initialized - show error if this is not the case
            print("No vendor was passed to this view controller")
            ViewService.showHUD(success: false, message: "Something went wrong. Please try again.")
            dismiss(animated: true, completion: nil)
        }
        
    }
    
    //
    // Updates UI to reflect current state
    //
    private func updateUI() {
        // Update the tableview
        itemsTableView.reloadData()
        ViewService.updateTableViewSize(tableView: itemsTableView, tableViewHeightConstraint: itemsTableHeight)
        ViewService.updateScrollViewSize(for: parentScrollView)
        
        // Update the total price
        totalAmountLabel.text = TextFormatterService.getCurrencyString(for: getTotalCost())
    }
    
    //
    // MARK: Cart methods
    //
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scannedProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let shoppingItemCell = tableView.dequeueReusableCell(withIdentifier: "ShoppingItemTableViewCell") as! ShoppingItemTableViewCell
        // Pass in params
        let product = scannedProducts[indexPath.row]
        let quantity = quantities[indexPath.row]
        shoppingItemCell.loadUI(for: product, with: quantity)
        return shoppingItemCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO - show the edit prompt
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Bottom add item button pressed. Should show a new barcode scanner VC
    @IBAction func addItemButtonPressed(_ sender: UIButton) {
        // Launch barcode view controller
        // Create the VC then present it modally
        let barcodeScannerVC = ViewService.getBarcodeScannerVC(with: "Scan New Item")
        barcodeScannerVC.codeDelegate = self
        barcodeScannerVC.dismissalDelegate = self
        present(barcodeScannerVC, animated: true, completion: nil)
    }
    
    // Clear cart button pressed. Clear all the arrays if confirmed
    @IBAction func clearCartButtonPressed(_ sender: UIButton) {
        // TODO confirmation dialog
        scannedProducts = []
        quantities = []
        updateUI()
    }
    
    // Calculates total in cart
    private func getTotalCost() -> Double {
        var totalPrice = 0.0
        for index in 0..<scannedProducts.count {
            totalPrice = totalPrice + scannedProducts[index].cost * Double(quantities[index])
        }
        return totalPrice
    }
    
    //
    // MARK: Navigation button pressed methods
    //
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        // TODO confirmation dialog
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func checkoutButtonPressed(_ sender: UIBarButtonItem) {
        // TODO confirmation dialog
        performSegue(withIdentifier: "CartToCheckoutSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CartToCheckoutSegue" {
            // Initialize VC with the required fields (cost & vendor) 
            let destinationVC = segue.destination as! CheckoutViewController
            destinationVC.cost = getTotalCost()
            destinationVC.vendor = vendor
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
        
        // Call firebase to see if this is a valid store
        FirebaseService.getProduct(from: vendor!.id, for: code) { (product) in
            if let product = product {
                controller.dismiss(animated: true) {
                    print("Product found: id: \(product.id), name: \(product.name)")
                    // Add the product to the shopping list, then update the UI
                    if let itemIndex = self.scannedProducts.firstIndex(of: product) {
                        // First determine if the item has already been added - if so, we just increase the quantity
                        self.quantities[itemIndex] = self.quantities[itemIndex] + 1
                    } else {
                        // Else, just add to the scanned products & quantities array
                        self.scannedProducts.append(product)
                        self.quantities.append(1)
                    }
                    self.updateUI()
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
