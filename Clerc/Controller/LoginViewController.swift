//
//  LoginViewController.swift
//  Clerc
//
//  Created by Frank Jia on 2019-03-22.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import UIKit
import FirebaseUI

class LoginViewController: UIViewController, FUIAuthDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func loginPressed(_ sender: UIButton) {
        // Retrieve the authentication UI instance
        let authUI = FUIAuth.defaultAuthUI()
        if let auth = authUI {
            // Set up providers
            auth.delegate = self
            auth.providers = [FUIGoogleAuth()]
            
            // Change styling of view controller & present it
            let authViewController = FUIAuth.defaultAuthUI()!.authViewController()
            present(authViewController, animated: true, completion: nil)
        } else {
            print("Error creating auth UI object")
            ViewService.showHUD(success: false, message: "Something went wrong. Please try again.")
        }
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        if error != nil {
            FirebaseService.saveCustomer(user!) { (success) in
                if success {
                    print("User logged in and user was saved successfully")
                    // Segue to home
                } else {
                    print("Firebase save user failed")
                    ViewService.showHUD(success: false, message: "Something went wrong. Please try again.")
                }
            }
        } else {
            // Something errored
            print("Error in sign-in: \(error!)")
            ViewService.showHUD(success: false, message: "Something went wrong. Please try again.")
        }
    }
    
}
