//
//  PaymentSuccessViewController.swift
//  Clerc
//
//  Created by Frank Jia on 2019-03-14.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import UIKit

class PaymentSuccessViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Dismiss when done pressed
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

}
