//
//  InfoDialogView.swift
//  Clerc
//
//  Created by Frank Jia on 2019-05-14.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import UIKit
import SwiftEntryKit

class InfoDialogView: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    var titleString: String
    var descString: String

    init(title: String, desc: String) {
        self.titleString = title
        self.descString = desc
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = titleString
        descriptionLabel.text = descString

        // Give the view corners
        view.layer.cornerRadius = ViewConstants.POPUP_CORNER_RADIUS;
        view.layer.masksToBounds = true;

    }

    @IBAction func dismissButtonPressed(_ sender: UIButton) {
        SwiftEntryKit.dismiss()
    }

}
