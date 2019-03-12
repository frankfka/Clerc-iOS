//
//  ConfirmationDialog.swift
//  Clerc
//
//  Created by Frank Jia on 2019-03-10.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import UIKit
import SwiftEntryKit

class ConfirmationDialog: UIViewController {

    @IBOutlet weak var textField: UITextField!

    var delegate: ConfirmationDialogDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func buttonPressed(_ sender: UIButton) {
        if let delegate = delegate {
            delegate.didDismiss(with: textField.text!)
        }
        SwiftEntryKit.dismiss()
    }

}

protocol ConfirmationDialogDelegate {
    // Classes that adopt this protocol MUST define
    // this method -- and hopefully do something in
    // that definition.
    func didDismiss(with value: String)
}
