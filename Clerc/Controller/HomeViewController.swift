//
//  ViewController.swift
//  MobileCheckout
//
//  Created by Frank Jia on 2019-03-09.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import UIKit
import BarcodeScanner
import AVFoundation
import FirebaseFirestore
import RealmSwift

class HomeViewController: UIViewController {
    
    private let DEFAULT_NO_PAST_TXN_VIEW_HEIGHT = CGFloat(400)
    
    let realm = try! Realm()
    let viewService = ViewService.shared
    
    // Used in segue initialization to tell next controller what store was scanned
    var scannedStore: Store?
    var pastTransactions: Results<Transaction>?
    
    // UI Elements
    @IBOutlet weak var pastTransactionsTable: UITableView!
    @IBOutlet weak var pastTransactionsTableHeight: NSLayoutConstraint!
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var noPastTransactionsView: UIView!
    @IBOutlet weak var noPastTransactionsHeight: NSLayoutConstraint!
    @IBOutlet weak var pastTransactionsParentView: UIView!
    
    // Initial setup on view load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get the past transactions
        pastTransactions = realm.objects(Transaction.self).sorted(byKeyPath: "txnDate", ascending: false)
        
        pastTransactionsTable.register(UINib(nibName: "TransactionTableViewCell", bundle: nil), forCellReuseIdentifier: "TransactionTableViewCell")
        pastTransactionsTable.dataSource = self
        pastTransactionsTable.delegate = self
        
        loadUI()
        
    }
    
    // Reload the tableview every time we return to this VC
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadUI()
    }
    
    // Private function to reload views
    private func loadUI() {
        pastTransactionsTable.reloadData()
        viewService.updateTableViewSize(tableView: pastTransactionsTable, tableViewHeightConstraint: pastTransactionsTableHeight)
        viewService.updateScrollViewSize(for: mainScrollView)
        if pastTransactions?.isEmpty ?? true {
            noPastTransactionsView.isHidden = false
            noPastTransactionsHeight.constant = DEFAULT_NO_PAST_TXN_VIEW_HEIGHT
            pastTransactionsParentView.isHidden = true
        } else {
            pastTransactionsParentView.isHidden = false
            noPastTransactionsView.isHidden = true
            noPastTransactionsHeight.constant = CGFloat(0)
        }
    }
    
    // When shopping button is pressed, launch the barcode scanner view controller
    @IBAction func beginShoppingPressed(_ sender: UIButton) {
        // Create the VC then present it modally
        let barcodeScannerVC = ViewService.shared.getBarcodeScannerVC(with: "Scan Store QR")
        barcodeScannerVC.codeDelegate = self
        barcodeScannerVC.dismissalDelegate = self
        present(barcodeScannerVC, animated: true, completion: nil)
    }
    
    // Called when a store was successfully identified and returned
    private func retailerScanSuccess(with store: Store) {
        // Segue into the shopping view
        print("Store \(store.name) found successfully")
        scannedStore = store
        performSegue(withIdentifier: "HomeToShoppingSegue", sender: self)
    }
    
    // Segue initialization
    // HOMETOSHOPPING - Send the store object
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "HomeToShoppingSegue") {
            // Get destination VC and set its store object - need to bypass the initial nav controller
            let navigationVC = segue.destination as! UINavigationController
            let destinationVC = navigationVC.topViewController as! ShoppingViewController
            destinationVC.store = scannedStore!
        }
    }
}

//
// MARK: Tableview delegates
//
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = pastTransactionsTable.dequeueReusableCell(withIdentifier: "TransactionTableViewCell") as! TransactionTableViewCell
        // Don't do anything if the transaction is somehow nil
        if let transaction = pastTransactions?[indexPath.row] {
            cell.loadUI(for: transaction)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pastTransactions?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let transaction = pastTransactions?[indexPath.row] {
            // Show details view
            viewService.showTransactionDetailsView(for: transaction)
        } else {
            viewService.showStandardErrorHUD()
        }
    }
    
}

//
// MARK: Extension for all barcode methods (to identify a retailer)
//
extension HomeViewController: BarcodeScannerCodeDelegate, BarcodeScannerDismissalDelegate {
    
    // Function called when code is captured
    func scanner(_ controller: BarcodeScannerViewController, didCaptureCode code: String, type: String) {
        
        print("Barcode Data: \(code) | Type: \(type)")
        
        // Check that the barcode is a QR code
        if (type == "org.iso.QRCode") {
            // Call firebase to see if this is a valid store
            FirebaseService.shared.getStore(with: code) { (store) in
                if let store = store {
                    controller.dismiss(animated: true) {
                        self.retailerScanSuccess(with: store)
                    }
                } else {
                    print("Could not find barcode in Firebase")
                    DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(ViewConstants.BARCODE_ERROR_TIME)) {
                        controller.resetWithError(message: "No store found. Please try again.")
                    }
                }
            }
        } else {
            // Not the correct type of code, do nothing
            print("Invalid barcode format")
            // Display an error message
            DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(ViewConstants.BARCODE_ERROR_TIME)) {
                controller.resetWithError(message: "No store found. Please try again.")
            }
        }
    }
    
    // Called when user clicks "Cancel" on the barcode scanning view controller
    func scannerDidDismiss(_ controller: BarcodeScannerViewController) {
        // Dismiss the view controller
        controller.dismiss(animated: true, completion: nil)
    }
    
}

