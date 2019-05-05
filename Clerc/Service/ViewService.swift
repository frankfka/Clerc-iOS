//
//  ViewService.swift
//  Clerc
//
//  Created by Frank Jia on 2019-03-09.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import Foundation
import SVProgressHUD
import BarcodeScanner
import SwiftEntryKit

class ViewService {
    
    static let shared = ViewService()
    
    // Show a popup HUD with a specified success/fail and message
    func showHUD(success: Bool, message: String) {
        if (success) {
            SVProgressHUD.showSuccess(withStatus: message)
        } else {
            SVProgressHUD.showError(withStatus: message)
        }
        SVProgressHUD.dismiss(withDelay: TimeInterval(ViewConstants.HUD_TIME))
    }
    
    // Show a standard error HUD
    func showStandardErrorHUD() {
        showHUD(success: false, message: "Something went wrong. Please try again.")
    }
    
    // Show loading animation
    func loadingAnimation(show: Bool, with message: String? = "Please wait") {
        if show {
            SVProgressHUD.show(withStatus: message)
        } else {
            SVProgressHUD.dismiss()
        }
    }
    
    // Update size of a tableview such that there is no scrolling & all of its contents fit
    func updateTableViewSize(tableView: UITableView, tableViewHeightConstraint: NSLayoutConstraint) {
        // We want to fit the entire tableview, so disable scroll
        tableView.isScrollEnabled = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        
        // Make tableview very big so that all the cells show
        tableViewHeightConstraint.constant = 1000
        UIView.animate(withDuration: 0, animations: {
            tableView.layoutIfNeeded()
        }) { (complete) in
            
            var heightOfTableView: CGFloat = 0.0
            // Get visible cells and sum up their heights
            let cells = tableView.visibleCells
            for cell in cells {
                heightOfTableView += cell.frame.height
            }
            // Update tableview height with new constant from the sum
            tableViewHeightConstraint.constant = heightOfTableView
            
        }
    }
    
    // Updates the size of a scrollview to fit all of its contents
    func updateScrollViewSize(for scrollView: UIScrollView, with minHeight: CGFloat = CGFloat(integerLiteral: 0)) {
        
        // Sum up height of all the subviews
        var contentRect = CGRect.zero
        for view in scrollView.subviews {
            contentRect = contentRect.union(view.frame)
        }
        // Set scrollview size
        if minHeight > contentRect.size.height {
            scrollView.contentSize.height = minHeight
        } else {
            scrollView.contentSize = contentRect.size
        }
        
    }
    
    // Creates a barcode scanner with default styling
    func getBarcodeScannerVC(with title: String) -> BarcodeScannerViewController {
        let barcodeScannerVC = BarcodeScannerViewController()
        // No Scanning animation
        barcodeScannerVC.cameraViewController.barCodeFocusViewType = .twoDimensions
        barcodeScannerVC.headerViewController.titleLabel.text = title
        // Initialize colors
        barcodeScannerVC.headerViewController.closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 17.0)
        barcodeScannerVC.headerViewController.closeButton.tintColor = UIColor(named: "Primary")!
        return barcodeScannerVC
    }
    
    // Creates and shows a confirmation dialog
    func showConfirmationDialog(title: String, description: String, completion: @escaping (_ didConfirm: Bool) -> Void) {
        // Create the dialog VC and initialize it
        let confirmationDialog = ConfirmDialogView()
        confirmationDialog.initialize(title: title, desc: description, completionHandler: completion)
        // Tell SwiftEntryKit to display with our standard attributes
        SwiftEntryKit.display(entry: confirmationDialog, using: ViewConstants.CONFIRM_POPUP_ATTRIBUTES)
    }
    
    // Creates and shows an edit item dialog
    func showEditItemDialog(for product: Product, with quantity: Int, completion: @escaping (_ newQuantity: Int) -> Void) {
        // Create the dialog VC and initialize it
        let editItemPopUp = EditItemView()
        editItemPopUp.initialize(name: product.name, unitCost: product.cost, currentQuantity: quantity, completion: completion)
        // Tell SwiftEntryKit to display with our standard attributes
        SwiftEntryKit.display(entry: editItemPopUp, using: ViewConstants.EDIT_ITEM_POPUP_ATTRIBUTES)
    }
    
    // Enables or disables a button
    func setButtonState(button: UIButton, enabled: Bool) {
        if enabled {
            button.isEnabled = true
            button.alpha = 1
        } else {
            button.isEnabled = false
            button.alpha = 0.2
        }
    }
    
}
