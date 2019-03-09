//
//  ViewController.swift
//  MobileCheckout
//
//  Created by Frank Jia on 2019-03-09.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import UIKit
import BarcodeScanner

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    
}

// MARK: Extension for all barcode methods (to identify a retailer)
extension HomeViewController: BarcodeScannerCodeDelegate, BarcodeScannerErrorDelegate, BarcodeScannerDismissalDelegate {
    
    func scanner(_ controller: BarcodeScannerViewController, didCaptureCode code: String, type: String) {
        return
    }
    
    func scanner(_ controller: BarcodeScannerViewController, didReceiveError error: Error) {
        return
    }
    
    func scannerDidDismiss(_ controller: BarcodeScannerViewController) {
        return
    }
    
    
    @IBAction func beginShoppingPressed(_ sender: UIButton) {
        // Create the VC then present it modally
        let barcodeScannerVC = BarcodeScannerViewController()
        barcodeScannerVC.codeDelegate = self
        barcodeScannerVC.errorDelegate = self
        barcodeScannerVC.dismissalDelegate = self
        present(barcodeScannerVC, animated: true) {
            self.didReturnFromScan()
        }
    }
    
    // Called when we return from scanning for a barcode 
    private func didReturnFromScan() {
        print("returned from scanning")
    }
    
}

