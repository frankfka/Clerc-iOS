//
//  ShoppingViewController.swift
//  Clerc
//
//  Created by Frank Jia on 2019-03-10.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import UIKit
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

        if vendor != nil {
            // Set title
            navigationBar.title = vendor?.name
            updateUI()
        } else {
            // Vendor should always be initialized - show error if this is not the case
            print("No vendor was passed to this view controller")
            ViewService.showHUD(success: false, message: "Something went wrong. Please try again.")
            dismiss(animated: true, completion: nil)
        }
        
    }
    
    // Initializes UI
    private func updateUI() {
        // Call stuff like update tableview & scroll view constraints here 
    }
    
    // MARK: Cart methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scannedProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let shoppingItemCell = tableView.dequeueReusableCell(withIdentifier: "ShoppingItemTableCell") as! ShoppingItemTableViewCell
        // Pass in params
        return shoppingItemCell
    }
    
    // Bottom add item button pressed. Should show a new barcode scanner VC
    @IBAction func addItemButtonPressed(_ sender: UIButton) {
        // Launch barcode view controller
    }
    
    // Clear cart button pressed. Clear all the arrays if confirmed
    @IBAction func clearCartButtonPressed(_ sender: UIButton) {
        print("Clear cart")
    }
    
    // MARK: Navigation button pressed methods
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func checkoutButtonPressed(_ sender: UIBarButtonItem) {
        print("Go to checkout")
    }
    
}
