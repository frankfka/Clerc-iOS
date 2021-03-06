//
//  BackendService.swift
//  Clerc
//
//  Created by Frank Jia on 2019-03-12.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import Foundation
import Stripe
import Alamofire

class BackendService: NSObject, STPEphemeralKeyProvider {
    
    static let shared = BackendService()
    
    let baseURL = URL(string: StripeConstants.BACKEND_URL)!
    let utilityService = UtilityService.shared
    
    // Calls backend to charge the customer
    func completeCharge(_ result: STPPaymentResult, amount: Int, store: Store, completion: @escaping (_ success: Bool, _ txnId: String?, _ error: Error?) -> Void) {
        // Check that current customer exists
        guard let currentCustomer = Customer.current else {
            print("No current customer!")
            completion(false, nil, nil)
            return
        }
        // Get JWT token
        JWT.getToken { token in
            
            // Check that we could retrieve a valid token, else we just return
            if token == nil {
                print("Charge not completed - could not get JWT")
                completion(false, nil, nil)
                return
            }
            
            // Else proceed normally
            let url = self.baseURL.appendingPathComponent("charge")
            // TODO: Charge description & descriptor
            let chargeParams: [String: Any] = [
                "token": token!,
                "customer_id": currentCustomer.stripeID,
                "amount": amount,
                "source": result.source.stripeID,
                "firebase_store_id": store.id
            ]
            AF.request(url, method: .post, parameters: chargeParams, encoding: JSONEncoding.default)
                .validate(statusCode: 200..<300)
                .responseJSON { responseJSON in
                    // TODO - get txn id, get proper params, finish writeTransaction, test!
                    switch responseJSON.result {
                    case .success(let json):
                        // In case backend screws up and doesn't return proper json
                        guard let txnData = json as? [String: AnyObject] else {
                            print("Backend not returning JSON!")
                            completion(true, nil, nil) // WARNING: Txn ID can still be nil if we "succeed" in the payment
                            return
                        }
                        // Call completion handler with the transaction ID
                        completion(true, txnData["charge_id"] as? String, nil)
                    case .failure(let error):
                        print("Charging customer failed: \(error)")
                        print("Server failure message: \(String(describing: self.utilityService.getErrorResponse(from: responseJSON)))")
                        completion(false, nil, error)
                    }
            }
            
        }
    }
    
    // Calls backend to create an ephemeral key
    func createCustomerKey(withAPIVersion apiVersion: String, completion: @escaping STPJSONResponseCompletionBlock) {
        let url = self.baseURL.appendingPathComponent("customers").appendingPathComponent("create-ephemeral-key")
        
        guard let currentCustomer = Customer.current else {
            print("No current customer!")
            // Pass an NSError to the completion so that we can signal that we have encountered an error
            completion(nil, NSError(domain: NSURLErrorDomain, code: NSURLErrorUnknown, userInfo: nil))
            return
        }
        
        // Get JWT token & call backend if that was successful
        JWT.getToken() { (token) in
            
            if token == nil {
                print("Could not get ephemeral key - could not get JWT")
                // Signal that we have an error
                completion(nil, NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotConnectToHost, userInfo: nil))
                return
            }
            
            // Params for backend call
            let createKeyParams = [
                "token": token!,
                "stripe_version": apiVersion,
                "customer_id": currentCustomer.stripeID
            ]
            AF.request(url, method: .post, parameters: createKeyParams, encoding: JSONEncoding.default)
                .validate(statusCode: 200..<300)
                .responseJSON { responseJSON in
                    switch responseJSON.result {
                    case .success(let json):
                        print("Success getting ephemeral key")
                        completion(json as? [String: AnyObject], nil)
                    case .failure(let error):
                        print("Get ephemeral key failed: \(error)")
                        print("Server failure message: \(String(describing: self.utilityService.getErrorResponse(from: responseJSON)))")
                        completion(nil, error)
                    }
            }
            
        }
        
    }
    
    // Creates a new customer and passes ID to callback
    func createCustomer(completion: @escaping (_ success: Bool, _ id: String?) -> Void) {
        
        let url = self.baseURL.appendingPathComponent("customers").appendingPathComponent("create")
        // Call create stripe customer
        AF.request(url, method: .post)
            .validate(statusCode: 200..<300)
            .responseJSON { responseJSON in
                switch responseJSON.result {
                case .success(let json):
                    // In case backend screws up and doesn't return proper json
                    guard let returnedData = json as? [String: AnyObject] else {
                        print("Backend not returning JSON!")
                        completion(false,nil)
                        return
                    }
                    // In case backend screws up and doesn't return a customer ID
                    guard let newCustId = returnedData["customer_id"] as? String else {
                        print("Backend did not return a customer ID!")
                        completion(false,nil)
                        return
                    }
                    // Call completion and return
                    completion(true, newCustId)
                    return
                case .failure(let error):
                    print("Make customer endpoint errored: \(error)")
                    print("Server failure message: \(String(describing: self.utilityService.getErrorResponse(from: responseJSON)))")
                }
                // Did not succeed, call completion
                completion(false, nil)
        }
    }
    
    // Calls backend to email a receipt
    func emailReceipt(txnId: String, completion: @escaping (_ success: Bool) -> Void) {
        
        // Check that current customer exists
        guard let currentCustomer = Customer.current else {
            print("No current customer!")
            completion(false)
            return
        }
        
        // Get JWT token & call backend if that was successful
        JWT.getToken() { (token) in
            
            if token == nil {
                print("Could not send email - could not get JWT")
                // Signal that we have an error
                completion(false)
                return
            }
            
            let url = self.baseURL.appendingPathComponent("customers").appendingPathComponent("email-receipt")
            // Params for backend call
            let emailParams = [
                "token": token!,
                "txn_id": txnId,
                "customer_name": currentCustomer.name ?? "",
                "customer_email": currentCustomer.email ?? ""
            ]
            print("Requesting email receipt for transaction ID \(txnId)")
            AF.request(url, method: .post, parameters: emailParams, encoding: JSONEncoding.default)
                .validate(statusCode: 200..<300)
                .responseJSON { responseJSON in
                    switch responseJSON.result {
                    case .success(_):
                        print("Success sending email")
                        completion(true)
                    case .failure(let error):
                        print("Receipt email failed: \(error)")
                        print("Server failure message: \(String(describing: self.utilityService.getErrorResponse(from: responseJSON)))")
                        completion(false)
                    }
            }
        }
    }
    
    // This is used to compute Stripe cost in cents
    static func getStripeCost(for cost: Double) -> Int {
        return Int(cost*100)
    }
    
}
