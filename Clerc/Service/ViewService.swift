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
    
    static var popupAttributes: EKAttributes {
        var attributes = EKAttributes()
        attributes.position = .center
        attributes.screenBackground = .color(color: (UIColor(named: "Divider")!.withAlphaComponent(0.6)))
        attributes.entranceAnimation = .none
        attributes.exitAnimation = .none
        attributes.displayDuration = .infinity
        attributes.entryInteraction = .absorbTouches
        attributes.screenInteraction = .dismiss
        return attributes
    }
    
    // Show a popup HUD with a specified success/fail and message
    static func showHUD(success: Bool, message: String) {
        if (success) {
            SVProgressHUD.showSuccess(withStatus: message)
        } else {
            SVProgressHUD.showError(withStatus: message)
        }
        SVProgressHUD.dismiss(withDelay: TimeInterval(ViewConstants.HUD_TIME))
    }
    
    // Show loading animation
    static func loadingAnimation(show: Bool, with message: String? = nil) {
        if show {
            SVProgressHUD.show(withStatus: message)
        } else {
            SVProgressHUD.dismiss()
        }
    }
    
    // Update size of a tableview such that there is no scrolling & all of its contents fit
    static func updateTableViewSize(tableView: UITableView, tableViewHeightConstraint: NSLayoutConstraint) {
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
    static func updateScrollViewSize(for scrollView: UIScrollView, with minHeight: CGFloat = CGFloat(integerLiteral: 0)) {
        
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
    static func getBarcodeScannerVC(with title: String) -> BarcodeScannerViewController {
        let barcodeScannerVC = BarcodeScannerViewController()
        // No Scanning animation
        barcodeScannerVC.cameraViewController.barCodeFocusViewType = .twoDimensions
        barcodeScannerVC.headerViewController.titleLabel.text = title
        // Initialize colors
        barcodeScannerVC.headerViewController.closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 17.0)
        barcodeScannerVC.headerViewController.closeButton.tintColor = UIColor(named: "Primary")!
        return barcodeScannerVC
    }
    
    static func showConfirmationDialog(title: String, description: String, completion: @escaping (_ didConfirm: Bool) -> Void) {
        let confirmationDialog = ConfirmDialogView()
        confirmationDialog.initialize(title: title, desc: description, completionHandler: completion)
        SwiftEntryKit.display(entry: confirmationDialog, using: popupAttributes)
    }
    
}
