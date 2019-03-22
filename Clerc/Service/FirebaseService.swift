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
    
    static let database = Firestore.firestore()
    
    // Saves a user to firestore and creates a new Stripe customer if one does not exist
    static func saveCustomer(_ user: User, completion: @escaping (_ success: Bool, _ customer: Customer?) -> Void) {
        // Get reference to document (most likely won't exist if the user is logging in for the first time)
    }
    
    // Retrieve a vendor from firebase
    static func getVendor(with vendorId: String, completionHandler: @escaping (_ result: Vendor?) -> Void) {
        // Get a reference to the document, which may or may not exist
        getVendorDocRef(with: vendorId).getDocument { (vendorDocument, error) in
            // Check that the document actually exists
            if let vendorDocument = vendorDocument, vendorDocument.exists {
                // Vendor found, create the object
                let vendorData = vendorDocument.data()
                // These should always exist
                // TODO we may benefit from additional error checking
                let vendorName = vendorData!["name"] as! String
                let stripeId = vendorData!["stripeId"] as! String
                // Pass the vendor object to the completion handler, then return
                completionHandler(Vendor(id: vendorId, name: vendorName, stripeId: stripeId))
            } else {
                completionHandler(nil)
            }
        }
    }
    
    // Retrieve a product from firebase
    static func getProduct(from vendorId: String, for productId: String, completionHandler: @escaping (_ result: Product?) -> Void) {
        // Get reference to the document, which may or may not exist
        getProductDocRef(from: vendorId, with: productId).getDocument { (productDocument, error) in
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
    private static func getUserDocRef(with userId: String) -> DocumentReference {
        return database.collection(FirebaseConstants.USERS_COL).document(userId)
    }
    
    // Gets a Firebase document reference for the vendor
    private static func getVendorDocRef(with vendorId: String) -> DocumentReference {
        return database.collection(FirebaseConstants.VENDORS_COL).document(vendorId)
    }
    
    // Gets a Firebase document reference for the product
    private static func getProductDocRef(from vendorId: String, with productId: String) -> DocumentReference {
        return getVendorDocRef(with: vendorId).collection(FirebaseConstants.PRODUCTS_COL).document(productId)
    }
    
}
