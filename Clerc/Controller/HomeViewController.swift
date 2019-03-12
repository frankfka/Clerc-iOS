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

class HomeViewController: UIViewController {
    
    // Used in segue initialization to tell next controller what vendor was scanned
    var scannedVendor: Vendor?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    // When shopping button is pressed, launch the barcode scanner view controller
    @IBAction func beginShoppingPressed(_ sender: UIButton) {
        // Create the VC then present it modally
        let barcodeScannerVC = ViewService.getBarcodeScannerVC(with: "Scan Store QR")
        barcodeScannerVC.codeDelegate = self
        barcodeScannerVC.dismissalDelegate = self
        present(barcodeScannerVC, animated: true, completion: nil)
    }
    
    // Called when a store was successfully identified and returned
    private func retailerScanSuccess(with vendor: Vendor) {
        // Segue into the shopping view
        print("Vendor \(vendor.name) found successfully")
        scannedVendor = vendor
        performSegue(withIdentifier: "HomeToShoppingSegue", sender: self)
    }
    
    // Segue initialization
    // HOMETOSHOPPING - Send the vendor object
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "HomeToShoppingSegue") {
            // Get destination VC and set its vendor object - need to bypass the initial nav controller
            let navigationVC = segue.destination as! UINavigationController
            let destinationVC = navigationVC.topViewController as! ShoppingViewController
            destinationVC.vendor = scannedVendor! 
        }
    }
    
    
    
}

// MARK: Extension for all barcode methods (to identify a retailer)
extension HomeViewController: BarcodeScannerCodeDelegate, BarcodeScannerDismissalDelegate {
    
    // Function called when code is captured
    func scanner(_ controller: BarcodeScannerViewController, didCaptureCode code: String, type: String) {
        
        print("Barcode Data: \(code) | Type: \(type)")
        
        // Check that the barcode is a QR code
        if (type == "org.iso.QRCode") {
            // Call firebase to see if this is a valid store
            FirebaseService.getVendor(with: code) { (vendor) in
                if let vendor = vendor {
                    controller.dismiss(animated: true) {
                        self.retailerScanSuccess(with: vendor)
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

