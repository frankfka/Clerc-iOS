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
    var completion: ((_ didConfirm: Bool)->Void)
    var titleString: String
    var descString: String

    init(title: String, desc: String, completionHandler: @escaping (_ didConfirm: Bool) -> Void) {
        self.titleString = title
        self.descString = desc
        self.completion = completionHandler
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = titleString
        dialogDescription.text = descString
        
        // Give the view corners
        view.layer.cornerRadius = ViewConstants.POPUP_CORNER_RADIUS;
        view.layer.masksToBounds = true;
        
    }
    
    // Dismiss and tell completion that user confirmed the dialog
    @IBAction func confirmButtonPressed(_ sender: Any) {
        SwiftEntryKit.dismiss {
            self.completion(true)
        }
    }
    
    // Dismiss and notify that user did not confirm
    @IBAction func cancelButtonPressed(_ sender: Any) {
        SwiftEntryKit.dismiss {
            self.completion(false)
        }
    }
    

}
