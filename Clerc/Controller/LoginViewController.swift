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
            authViewController.navigationBar.tintColor = UIColor(named: "Primary")!
            present(authViewController, animated: true, completion: nil)
        } else {
            print("Error creating auth UI object")
            ViewService.showHUD(success: false, message: "Something went wrong. Please try again.")
        }
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        if error == nil && user != nil {
            // Start showing loading animation - this may take a while
            ViewService.loadingAnimation(show: true)
            
            FirebaseService.loadCustomer(user!) { (success, customer) in
                // Stop showing loading animation
                ViewService.loadingAnimation(show: false)
                
                if success && customer != nil {
                    print("User logged in and user was saved successfully")
                    // Set the customer singleton
                    Customer.current = customer!
                    print("Current customer initialized: \(Customer.current!.firebaseID)")
                    // Segue to home
                    self.performSegue(withIdentifier: "LoginToHomeSegue", sender: self)
                } else {
                    print("Firebase save user failed")
                    ViewService.showHUD(success: false, message: "Something went wrong. Please try again.")
                }
            }
        } else {
            print("User did not sign in successfully")
            // Error is not nil if user cancels sign in, so do nothing for now
        }
    }
    
}
