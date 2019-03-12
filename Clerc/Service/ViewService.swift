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

class ViewService {
    
    // Show a popup HUD with a specified success/fail and message
    static func showHUD(success: Bool, message: String) {
        if (success) {
            SVProgressHUD.showSuccess(withStatus: message)
        } else {
            SVProgressHUD.showError(withStatus: message)
        }
        SVProgressHUD.dismiss(withDelay: TimeInterval(ViewConstants.HUD_TIME))
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
    
    static func getBarcodeScannerVC(with title: String) -> BarcodeScannerViewController {
        let barcodeScannerVC = BarcodeScannerViewController()
        // No Scanning animation
        barcodeScannerVC.cameraViewController.barCodeFocusViewType = .twoDimensions
        barcodeScannerVC.headerViewController.titleLabel.text = title
        return barcodeScannerVC
    }
    
//    static func showConfirmation() {
//        var attributes = EKAttributes()
//        attributes.roundCorners = .all(radius: 4)
//        attributes.position = .center
//        attributes.screenBackground = .visualEffect(style: .dark)
//        attributes.entranceAnimation = .none
//        attributes.displayDuration = .infinity
//        attributes.entryInteraction = .absorbTouches
//        attributes.screenInteraction = .dismiss
//        let confirmationDialog = ConfirmationDialog()
//        let textField = confirmationDialog.textField
//        SwiftEntryKit.display(entry: confirmationDialog, using: attributes)
//    }
    
}
