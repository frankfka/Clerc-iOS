//
//  EditUnitItemView.swift
//  Clerc
//
//  Created by Frank Jia on 2019-03-15.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import UIKit
import ValueStepper
import SwiftEntryKit

class EditUnitItemView: UIViewController {

    // TODO: This is similar to EditWeighedItemView - can probably combine in the future
    // This is also set up for both weighed items & per-unit items, but UI is good only for unit

    // State variables
    var quantity: Double
    var product: Product
    var completion: ((_ newQty: Double)->Void)
    
    // UI Variables
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var totalCostLabel: UILabel!
    @IBOutlet weak var unitCostLabel: UILabel!
    @IBOutlet weak var qtyStepper: ValueStepper!
    @IBOutlet weak var productNameLabel: UILabel!

    init(product: Product, currentQuantity: Double, completion: @escaping ((_ newQty: Double)->Void)) {
        self.product = product
        self.quantity = currentQuantity
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Add corner radius to update button
        updateButton.layer.cornerRadius = ViewConstants.POPUP_BTN_CORNER_RADIUS
        updateButton.clipsToBounds = true
        
        // Assume everything is initialized
        qtyStepper.value = Double(quantity)
        qtyStepper.minimumValue = 0
        qtyStepper.maximumValue = 1000 // Cap to 1000 (hopefully nobody goes beyond this)
        if (product.priceUnit != Product.PriceUnit.unit) {
            qtyStepper.stepValue = 0.05
            qtyStepper.numberFormatter.minimumFractionDigits = 2
        }

        unitCostLabel.text = TextFormatterService.shared.getCurrencyString(for: product.cost) +
                TextFormatterService.shared.getPriceUnitLabel(product.priceUnit)
        productNameLabel.text = product.name
        updateTotalCostLabel()
        
    }

    @IBAction func updateButtonPressed(_ sender: Any) {
        // Pass back the quantity and dismiss
        SwiftEntryKit.dismiss {
            self.completion(self.quantity)
        }
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        // Dismiss and pass 0 as quantity
        SwiftEntryKit.dismiss {
            self.completion(0)
        }
    }
    
    @IBAction func qtyValueChanged(_ sender: ValueStepper) {
        // Update total cost
        quantity = sender.value
        updateTotalCostLabel()
    }
    
    // Updates total cost label
    private func updateTotalCostLabel() {
        totalCostLabel.text = TextFormatterService.shared.getCurrencyString(for: quantity * product.cost)
    }
    
}
