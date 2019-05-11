//
//  ShoppingItemTableViewCell.swift
//  Clerc
//
//  Created by Frank Jia on 2019-03-10.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import UIKit

class ProductTableViewCell: UITableViewCell {

    // UI elements
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var costQtyLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func loadUI(for product: Product, with quantity: Double) {
        let textFormatter = TextFormatterService.shared
        priceLabel.text = textFormatter.getCurrencyString(for: product.cost * quantity)
        nameLabel.text = product.name
        // Create the detail text based on the type of product
        // FORMAT: $x.xx/lb x 2.32lb OR $x.xx ea. x 3
        let costUnitText = textFormatter.getPriceUnitLabel(product.priceUnit)
        let quantityText:String = (product.priceUnit == .unit) ?
                String(Int(quantity)) : (textFormatter.getRoundedNumberString(number: quantity, maxFractionDigits: 2) + " \(product.priceUnit.rawValue)")
        costQtyLabel.text = "\(textFormatter.getCurrencyString(for: product.cost))\(costUnitText) x \(quantityText)"
    }

    
}
