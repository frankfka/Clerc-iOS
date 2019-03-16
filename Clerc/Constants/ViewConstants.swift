//
//  ViewConstants.swift
//  Clerc
//
//  Created by Frank Jia on 2019-03-12.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import Foundation
import UIKit
import SwiftEntryKit

class ViewConstants {
    
    // Delay time to show error message in barcode scanner (in seconds)
    static let BARCODE_ERROR_TIME = 1
    // HUD Display time in seconds
    static let HUD_TIME = 2
    // Corner rounding constant for popups
    static let POPUP_CORNER_RADIUS: CGFloat = 8.0
    // Corner rounding constant for popup buttons
    static let POPUP_BTN_CORNER_RADIUS: CGFloat = 4.0
    // Attributes for confirmation dialog
    static var CONFIRM_POPUP_ATTRIBUTES: EKAttributes {
        var attributes = EKAttributes()
        attributes.position = .center
        attributes.screenBackground = .color(color: (UIColor(named: "Divider")!.withAlphaComponent(0.6)))
        attributes.entranceAnimation = .init(
            scale: .init(from: 0.6, to: 1, duration: 0.1),
            fade: .init(from: 0.8, to: 1, duration: 0.1))
        attributes.exitAnimation = .none
        attributes.displayDuration = .infinity
        attributes.entryInteraction = .absorbTouches
        attributes.screenInteraction = .dismiss
        attributes.scroll = .disabled
        return attributes
    }
    // Attributes for edit item dialog
    static var EDIT_ITEM_POPUP_ATTRIBUTES: EKAttributes {
        var attributes = EKAttributes()
        attributes.position = .bottom
        // Use a slightly less accented background alpha
        attributes.screenBackground = .color(color: (UIColor(named: "Divider")!.withAlphaComponent(0.4)))
        attributes.displayDuration = .infinity
        attributes.entryInteraction = .absorbTouches
        attributes.screenInteraction = .dismiss
        attributes.scroll = .edgeCrossingDisabled(swipeable: true)
        return attributes
    }
    
}
