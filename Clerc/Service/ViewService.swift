//
//  ViewService.swift
//  Clerc
//
//  Created by Frank Jia on 2019-03-09.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import Foundation
import SVProgressHUD

class ViewService {
    
    // HUD Display time in seconds
    static let HUD_TIME = 2
    
    static func showHUD(success: Bool, message: String) {
        if (success) {
            SVProgressHUD.showSuccess(withStatus: message)
        } else {
            SVProgressHUD.showError(withStatus: message)
        }
        SVProgressHUD.dismiss(withDelay: TimeInterval(HUD_TIME))
    }
    
}
