//
//  JWT.swift
//  Clerc
//
//  Created by Frank Jia on 2019-04-17.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import Foundation
import Alamofire

class JWT {
    
    // Build the backend URL
    static let newJwtUrl = URL(string: StripeConstants.BACKEND_URL)!
        .appendingPathComponent("jwt")
        .appendingPathComponent("refresh")
    
    static var currentToken: String?
    static var lastUpdated: Date?
    static let expiryTime: TimeInterval = TimeInterval(exactly: 30)! // Expire earlier than backend to account for time mismatch
    
    // Retrieves token and passes it to the completion handler
    // If an unexpired token exists,
    static func getToken(completion: @escaping (_ token: String?) -> Void) {
        let currentTime = Date()
        // The following makes sure things aren't nil
        // And compares using a simple < operator - this is possible because Date conforms to equatable
        if currentToken != nil && lastUpdated != nil && lastUpdated!.addingTimeInterval(expiryTime) < currentTime {
            // We can just use current token
            completion(currentToken)
        } else {
            // Need to retrieve another token
            getNewToken() { (success, token, error) in
                if success && token != nil {
                    // Yay! Token retrieved successfully
                    completion(token)
                } else {
                    // Something went wrong - call completion with nil
                    print("Failed to retrieve new JWT token")
                    completion(nil)
                }
            }
        }
    }
    
    // Gets a new JWT token & passes it to completion handler
    private static func getNewToken(completion: @escaping (_ success: Bool, _ token: String?, _ error: Error?) -> Void) {
        // Get the current customer
        guard let currentCustomer = Customer.current else {
            print("No current customer - cannot request JWT")
            // Update state & call completion
            updateJWTState(newToken: nil)
            completion(false, nil, nil)
            return
        }
        // Call backend for a new token
        let newJWTParams: [String: Any] = [
            "user_id": currentCustomer.firebaseID
        ]
        AF.request(newJwtUrl, method: .post, parameters: newJWTParams, encoding: JSONEncoding.default)
            .validate(statusCode: 200..<300)
            .responseJSON { responseJSON in
                switch responseJSON.result {
                case .success(let json):
                    // In case backend screws up and doesn't return proper json
                    guard let jwtData = json as? [String: String] else {
                        print("Backend not returning JSON!")
                        // Update state & call completion
                        updateJWTState(newToken: nil)
                        completion(false, nil, nil)
                        return
                    }
                    // Success - pass to completion & update state
                    let newToken = jwtData["token"]
                    updateJWTState(newToken: newToken)
                    completion(true, newToken, nil)
                case .failure(let error):
                    print("Call to get new JWT failed:\(error)")
                    // Update state & call completion
                    updateJWTState(newToken: nil)
                    completion(false, nil, error)
                    return
                }
        }
    }
    
    // Updates current state
    private static func updateJWTState(newToken: String?) {
        if let jwt = newToken {
            JWT.currentToken = jwt
            JWT.lastUpdated = Date()
        } else {
            JWT.currentToken = nil
            JWT.lastUpdated = nil
        }
    }
    
}
