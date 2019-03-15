//
//  ConfirmDialogView.swift
//  Clerc
//
//  Created by Frank Jia on 2019-03-15.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import UIKit
import SwiftEntryKit

class ConfirmDialogView: UIViewController {
    
    // UI Variables
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dialogDescription: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    
    // Completion handler to return result
    var completion: ((_ didConfirm: Bool)->Void)?
    var titleString: String?
    var descString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = titleString
        dialogDescription.text = descString
        
        // Give the view corners
        view.layer.cornerRadius = ViewConstants.POPUP_CORNER_RADIUS;
        view.layer.masksToBounds = true;
        
    }
    
    // Initialize the view controller. Might want to put this in init()
    func initialize(title: String, desc: String, completionHandler: @escaping (_ didConfirm: Bool) -> Void) {
        self.titleString = title
        self.descString = desc
        self.completion = completionHandler
    }
    
    // Dismiss and tell completion that user confirmed the dialog
    @IBAction func confirmButtonPressed(_ sender: Any) {
        SwiftEntryKit.dismiss {
            if let completion = self.completion {
                completion(true)
            }
        }
    }
    
    // Dismiss and notify that user did not confirm
    @IBAction func cancelButtonPressed(_ sender: Any) {
        SwiftEntryKit.dismiss {
            if let completion = self.completion {
                completion(false)
            }
        }
    }
    

}
