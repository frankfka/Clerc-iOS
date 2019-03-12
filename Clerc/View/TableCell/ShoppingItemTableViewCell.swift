//
//  ShoppingItemTableViewCell.swift
//  Clerc
//
//  Created by Frank Jia on 2019-03-10.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import UIKit

class ShoppingItemTableViewCell: UITableViewCell {

    // UI elements
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var costQtyLabel: UILabel!
    
    // State elements
    var name: String = ""
    var individualCost: Double = 0
    var quantity: Int = 0

    override func awakeFromNib() {
        super.awakeFromNib()
        loadUI() 
    }
    
    private func loadUI() {
        priceLabel.text = TextFormatterService.getCurrencyString(for: individualCost * Double(quantity))
        nameLabel.text = name
        costQtyLabel.text = "\(TextFormatterService.getCurrencyString(for: individualCost)) x \(quantity)"
    }
    
}
