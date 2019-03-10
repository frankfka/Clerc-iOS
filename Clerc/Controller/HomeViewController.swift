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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        controller.resetWithError(message: "No store found. Please try again.")
                    }
                }
            }
        } else {
            // Not the correct type of code, do nothing
            print("Invalid barcode format")
            // Display an error message
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                controller.resetWithError(message: "No store found. Please try again.")
            }
        }
    }
    
    func scannerDidDismiss(_ controller: BarcodeScannerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func beginShoppingPressed(_ sender: UIButton) {
        // Create the VC then present it modally
        let barcodeScannerVC = BarcodeScannerViewController()
        barcodeScannerVC.codeDelegate = self
        barcodeScannerVC.dismissalDelegate = self
        // No Scanning animation
        barcodeScannerVC.cameraViewController.barCodeFocusViewType = .twoDimensions
        barcodeScannerVC.headerViewController.titleLabel.text = "Scan Store QR"
        present(barcodeScannerVC, animated: true, completion: nil)
    }
    
    private func retailerScanSuccess(with vendor: Vendor) {
        // Segue into the shopping view
        print("returned")
    }
    
}

