//
//  FirebaseService.swift
//  Clerc
//
//  Created by Frank Jia on 2019-03-09.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class FirebaseService {
    
    static let shared = FirebaseService()
    
    let database = Firestore.firestore()
    
    // Saves a user to firestore and creates a new Stripe customer if one does not exist
    func loadCustomer(_ user: User, completion: @escaping (_ success: Bool, _ customer: Customer?) -> Void) {
        // Get reference to document (most likely won't exist if the user is logging in for the first time)
        let userDocRef = getUserDocRef(with: user.uid)
        // Try to get the document
        userDocRef.getDocument { (userDocument, error) in
            if let userDocument = userDocument, userDocument.exists {
                // User has signed in before - retrieve their info and call completion
                
                // Get their data
                let userData = userDocument.data()!
                let stripeId = userData["stripeId"] as! String
                // Creating a new customer object with their info
                completion(true, Customer(firebaseID: user.uid, stripeID: stripeId, name: user.displayName, email: user.email))
            } else {
                // User does not exist
                // Create the Stripe customer first - don't proceed unless this succeeds
                StripeService.shared.createCustomer() { (success, stripeId) in
                    if success && stripeId != nil {
                        // Stripe customer created, save to Firebase
                        
                        // We just save Stripe ID for now (safer) - do we want to save name/email?
                        let userData: [String: Any] = ["stripeId": stripeId!]
                        userDocRef.setData(userData) { error in
                            if error == nil {
                                // Successful - return customer object
                                completion(true, Customer(firebaseID: user.uid, stripeID: stripeId!, name: user.displayName, email: user.email))
                            } else {
                                // Unsuccessful
                                completion(false, nil)
                            }
                        }
                    } else {
                        // Something failed when creating a customer
                        print("Creating Stripe customer failed")
                        completion(false, nil)
                    }
                }
            }
        }
    }
    
    // Retrieve a store from firebase
    func getStore(with storeId: String, completionHandler: @escaping (_ result: Store?) -> Void) {
        // Get a reference to the document, which may or may not exist
        getStoreDocRef(with: storeId).getDocument { (storeDocument, error) in
            // Check that the document actually exists
            if let storeDocument = storeDocument, storeDocument.exists {
                // store found, create the object
                let storeData = storeDocument.data()
                // These should always exist
                // TODO we may benefit from additional error checking
                let storeName = storeData!["name"] as! String
                let stripeId = storeData!["stripeId"] as! String
                // Pass the store object to the completion handler, then return
                completionHandler(Store(id: storeId, name: storeName, stripeId: stripeId))
            } else {
                completionHandler(nil)
            }
        }
    }
    
    // Retrieve a product from firebase
    func getProduct(from storeId: String, for productId: String, completionHandler: @escaping (_ result: Product?) -> Void) {
        // Get reference to the document, which may or may not exist
        getProductDocRef(from: storeId, with: productId).getDocument { (productDocument, error) in
            // Check that the product exists first
            if let productDocument = productDocument, productDocument.exists {
                // Product exists, we can now create the object
                let productData = productDocument.data()
                // TODO extra error checking here?
                let productName = productData!["name"] as! String
                let cost = productData!["cost"] as! Double
                let currency = productData!["currency"] as! String
                completionHandler(Product(id: productId, name: productName, cost: cost, currency: currency))
            } else {
                completionHandler(nil)
            }
        }
        
    }
    
    // MARK: Helper functions
    // Gets a Firebase document reference for the user
    private func getUserDocRef(with userId: String) -> DocumentReference {
        return database.collection(FirebaseConstants.CUSTOMERS_COL).document(userId)
    }
    
    // Gets a Firebase document reference for the store
    private func getStoreDocRef(with storeId: String) -> DocumentReference {
        return database.collection(FirebaseConstants.STORES_COL).document(storeId)
    }
    
    // Gets a Firebase document reference for the product
    private func getProductDocRef(from storeId: String, with productId: String) -> DocumentReference {
        return getStoreDocRef(with: storeId).collection(FirebaseConstants.PRODUCTS_COL).document(productId)
    }
    
}
