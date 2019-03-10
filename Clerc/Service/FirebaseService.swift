//
//  FirebaseService.swift
//  Clerc
//
//  Created by Frank Jia on 2019-03-09.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import Foundation
import FirebaseFirestore

class FirebaseService {
    
    static let database = Firestore.firestore()
    
    // Retrieve a vendor from firebase
    static func getVendor(with vendorId: String, completionHandler: @escaping (_ result: Vendor?) -> Void) {
        // Get a reference to the document, which may or may not exist
        let vendorDocumentRef = database.collection("vendors").document(vendorId)
        vendorDocumentRef.getDocument { (vendorDocument, error) in
            // Check that the document actually exists
            if let vendorDocument = vendorDocument, vendorDocument.exists {
                // Vendor found, create the object
                let vendorData = vendorDocument.data()
                // These should always exist
                // TODO we may benefit from additional error checking
                let vendorName = vendorData!["name"] as! String
                let stripeId = vendorData!["stripeId"] as! String
                completionHandler(Vendor(id: vendorId, name: vendorName, stripeId: stripeId))
                return
            } else {
                completionHandler(nil)
            }
        }
    }
    
}
