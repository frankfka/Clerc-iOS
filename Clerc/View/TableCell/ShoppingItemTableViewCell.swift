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

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func loadUI(for product: Product, with quantity: Int) {
        priceLabel.text = TextFormatterService.getCurrencyString(for: product.cost * Double(quantity))
        nameLabel.text = product.name
        costQtyLabel.text = "\(TextFormatterService.getCurrencyString(for: product.cost)) x \(quantity)"
    }
    
}
