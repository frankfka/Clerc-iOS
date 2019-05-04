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
    let utilityService = UtilityService.shared
    
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
                // Store found, create the object
                let storeData = storeDocument.data()
                let storeName = storeData!["name"] as! String
                let taxRate = storeData!["tax_rate"] as? Double // May not exist, default to 0 (in constructor)
                let customSuccessMessage = storeData!["success_msg"] as? String
                // Pass the store object to the completion handler, then return
                completionHandler(Store(id: storeId, name: storeName, taxRate: taxRate ?? 0, successMessage: customSuccessMessage))
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
    
    // Write a transaction to firebase
    // Does nothing in case of failure - TODO resolve this somehow?
    func writeTransaction(from userId: String, to storeId: String, items: [Product], quantities: [Int], txnId: String) {
        
        //
        // Create document data
        //
        var itemsData: [[String:Any]] = []
        for index in 0..<items.count {
            let item = items[index]
            let itemData = [
                "id": item.id,
                "name": item.name,
                "cost": item.cost,
                "quantity": quantities[index]
                ] as [String : Any]
            itemsData.append(itemData)
        }
        let txnData = [
            "transaction_id": txnId,
            "customer_id": userId,
            "store_id": storeId,
            "currency": "cad",
            "amount": utilityService.getTotalCost(for: items, with: quantities),
            "date": Timestamp(date: Date()),
            "items": itemsData
            ] as [String : Any]
        
        // Get a reference to the transaction document (which should not yet exist)
        getTxnDocRef(with: txnId).setData(txnData) { (error) in
            // Just print error for now
            if error != nil {
                print("Error writing transaction to firebase: \(error!)")
            } else {
                print("Transaction \(txnId) successfully written to firebase")
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
    
    // Gets a Firebase document reference for the transaction
    private func getTxnDocRef(with txnId: String) -> DocumentReference {
        return database.collection(FirebaseConstants.TXN_COL).document(txnId)
    }
    
}
