//
//  LoginViewController.swift
//  Clerc
//
//  Created by Frank Jia on 2019-03-22.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import UIKit
import FirebaseUI
import EmptyDataSet_Swift

class LoginViewController: UIViewController, FUIAuthDelegate {

    @IBOutlet weak var emptyDatasetTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emptyDatasetTable.emptyDataSetSource = self
        emptyDatasetTable.emptyDataSetDelegate = self
    }
    
    // Called when login button is pressed
    @IBAction func loginPressed(_ sender: UIButton) {
        // Retrieve the authentication UI instance
        guard let auth = FUIAuth.defaultAuthUI() else {
            print("Error creating auth UI object")
            ViewService.shared.showStandardErrorHUD()
            return
        }
        // Set up providers
        auth.delegate = self
        auth.providers = [FUIGoogleAuth()]
        
        // Change styling of view controller & present it
        let authViewController = FUIAuth.defaultAuthUI()!.authViewController()
        authViewController.navigationBar.tintColor = UIColor(named: "Primary")!
        present(authViewController, animated: true, completion: nil)
    }
    
    // Called when user returns from Firebase Auth UI
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        if error == nil && user != nil {
            // Start showing loading animation - this may take a while
            ViewService.shared.loadingAnimation(show: true)
            
            FirebaseService.shared.loadCustomer(user!) { (success, customer) in
                // Stop showing loading animation
                ViewService.shared.loadingAnimation(show: false)
                
                if success && customer != nil {
                    print("User logged in and user was saved successfully")
                    // Set the customer singleton
                    Customer.current = customer!
                    print("Current customer initialized: \(Customer.current!.firebaseID)")
                    // Segue to home
                    self.performSegue(withIdentifier: "LoginToHomeSegue", sender: self)
                } else {
                    print("Firebase save user failed")
                    ViewService.shared.showStandardErrorHUD()
                }
            }
        } else {
            print("User did not sign in successfully")
            // Error is not nil if user cancels sign in, so do nothing for now
        }
    }
    
}

extension LoginViewController: EmptyDataSetSource, EmptyDataSetDelegate {
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "Scan. Pay. Go.")
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "Scan items and pay directly within the app. Clerc makes shopping easy, fun, and efficient.")
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "Login Illustration")
    }
    
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView) -> UIColor? {
        return UIColor.white
    }
    
    func emptyDataSetWillAppear(_ scrollView: UIScrollView) {
        emptyDatasetTable.separatorStyle = .none
    }
    
    func emptyDataSetWillDisappear(_ scrollView: UIScrollView) {
        emptyDatasetTable.separatorStyle = .singleLine
    }
    
}
