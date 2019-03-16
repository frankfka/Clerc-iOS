//
//  EditItemView.swift
//  Clerc
//
//  Created by Frank Jia on 2019-03-15.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import UIKit
import ValueStepper
import SwiftEntryKit

class EditItemView: UIViewController {
    
    // State variables
    var quantity: Int? // 1 by default
    var unitCost: Double? // 0 by default
    var productName: String?
    var completion: ((_ newQty: Int)->Void)?
    
    // UI Variables
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var totalCostLabel: UILabel!
    @IBOutlet weak var unitCostLabel: UILabel!
    @IBOutlet weak var qtyStepper: ValueStepper!
    @IBOutlet weak var productNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Add corner radius to update button
        updateButton.layer.cornerRadius = ViewConstants.POPUP_BTN_CORNER_RADIUS
        updateButton.clipsToBounds = true
        
        // Assume everything is initialized
        qtyStepper.value = Double(quantity!)
        unitCostLabel.text = TextFormatterService.getCurrencyString(for: unitCost!) + " ea."
        productNameLabel.text = productName!
        updateTotalCostLable()
        
    }
    
    // This should be an init constructor
    func initialize(name: String, unitCost: Double, currentQuantity: Int, completion: @escaping ((_ newQty: Int)->Void)) {
        self.productName = name
        self.unitCost = unitCost
        self.quantity = currentQuantity
        self.completion = completion
    }
    
    @IBAction func updateButtonPressed(_ sender: Any) {
        // Pass back the quantity and dismiss
        SwiftEntryKit.dismiss {
            self.completion!(self.quantity!)
        }
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        // Dismiss and pass 0 as quantity
        SwiftEntryKit.dismiss {
            self.completion!(0)
        }
    }
    
    @IBAction func qtyValueChanged(_ sender: ValueStepper) {
        // Update total cost
        quantity = Int(sender.value)
        updateTotalCostLable()
    }
    
    // Updates total cost label
    private func updateTotalCostLable() {
        totalCostLabel.text = TextFormatterService.getCurrencyString(for: Double(quantity!) * unitCost!)
    }
    
}
