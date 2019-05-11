//
//  EditWeighedItemView.swift
//  Clerc
//
//  Created by Frank Jia on 2019-05-09.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import UIKit
import SwiftEntryKit

class EditWeighedItemView: UIViewController {
    
    // TODO: This is VERY similar to EditUnitItemView
    // Need to refactor this and combine classes
    
    // State Variables
    var quantity: Double? {
        didSet {
            // When this is changed, reflect in total cost
            updateTotalCostLabel()
        }
    }
    var product: Product
    var completion: ((_ newQty: Double)->Void)
    
    // UI Variables
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var totalCostLabel: UILabel!
    @IBOutlet weak var unitCostLabel: UILabel!
    @IBOutlet weak var quantityEntryField: UITextField!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var priceUnitLabel: UILabel!
    
    init(product: Product, currentQuantity: Double?, completion: @escaping ((_ newQty: Double)->Void)) {
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
        unitCostLabel.text = TextFormatterService.shared.getCurrencyString(for: product.cost) +
            TextFormatterService.shared.getPriceUnitLabel(product.priceUnit)
        productNameLabel.text = product.name
        updateTotalCostLabel()
        
        // DIFFERENT FROM UNITEDITITEMVIEW
        priceUnitLabel.text = product.priceUnit.rawValue
        setupNumericalInput()
        // If quantity given, fill textfield
        if let qty = quantity {
            quantityEntryField.text = String(qty)
        }
    }

    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        // Dismiss and pass 0 as quantity
        SwiftEntryKit.dismiss {
            self.completion(0)
        }
    }
    
    @IBAction func updateButtonPressed(_ sender: UIButton) {
        // Pass back the quantity and dismiss
        SwiftEntryKit.dismiss {
            self.completion(self.quantity ?? 0)
        }
    }
    
    // Updates total cost label
    private func updateTotalCostLabel() {
        totalCostLabel.text = TextFormatterService.shared.getCurrencyString(for: (quantity ?? 0) * product.cost)
    }
    
}

// Extension for dealing with TextField - addition to EditItemView
extension EditWeighedItemView: UITextFieldDelegate {
    
    private func setupNumericalInput() {
        quantityEntryField.delegate = self
        quantityEntryField.keyboardType = .decimalPad
        addDoneButtonOnKeyboard()
    }
    
    // Only allow positive numerical inputs
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // Get the full string ("string" is only the current change)
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        let parsedNumber = getPositiveNumber(newText)
        
        // We'll try to parse the new number to update the field
        if let number = parsedNumber {
            // IMPORTANT - check for this first, so that we can properly update the field
            quantity = number
            return true
        } else if string.isEmpty {
            // Empty is when user has pressed delete key - should always return true
            return true
        }
        
        // Not a valid change
        return false
    }
    
    // Checks if a string is a positive numerical number and returns that number, or nil if invalid
    private func getPositiveNumber(_ input: String) -> Double? {
        // If valid number can be parsed, it is a valid double, check if positive
        if let number = NumberFormatter().number(from: input)?.doubleValue {
            return (number >= 0) ? number : nil
        }
        return nil
    }
    
    // Adds a toolbar to the keyboard with a done button - technically not necessary but might be good for UX
    private func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonOnKeyboardPressed))
        done.tintColor = UIColor(named: "Primary")
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        quantityEntryField.inputAccessoryView = doneToolbar
    }
    
    @objc private func doneButtonOnKeyboardPressed() {
        quantityEntryField.resignFirstResponder()
    }
    
}
