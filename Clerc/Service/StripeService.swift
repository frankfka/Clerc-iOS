//
//  StripeService.swift
//  Clerc
//
//  Created by Frank Jia on 2019-03-12.
//  Copyright © 2019 Frank Jia. All rights reserved.
//

import Foundation
import Stripe
import Alamofire

class StripeService: NSObject, STPEphemeralKeyProvider {
    
    static let shared = StripeService()
    let baseURL = URL(string: StripeConstants.BACKEND_URL)!
    
    // Calls backend to charge the customer
    func completeCharge(_ result: STPPaymentResult, amount: Int, store: Store, completion: @escaping STPErrorBlock) {
        // Check that current customer exists
        guard let currentCustomer = Customer.current else {
            // TODO this does nothing, but we would want to throw some sort of error
            print("No current customer!")
            return
        }
        let url = self.baseURL.appendingPathComponent("charge")
        // TODO: Charge description & descriptor
        let chargeParams: [String: Any] = [
            "customer_id": currentCustomer.stripeID,
            "amount": amount,
            "source": result.source.stripeID,
            "firebase_store_id": store.id
            ]
        AF.request(url, method: .post, parameters: chargeParams, encoding: JSONEncoding.default)
            .validate(statusCode: 200..<300)
            .responseString { response in
                switch response.result {
                case .success:
                    // TODO add transaction to firebase here!
                    completion(nil)
                case .failure(let error):
                    completion(error)
                }
        }
    }
    
    // Calls backend to create an ephemeral key
    func createCustomerKey(withAPIVersion apiVersion: String, completion: @escaping STPJSONResponseCompletionBlock) {
        let url = self.baseURL.appendingPathComponent("customers").appendingPathComponent("create-ephemeral-key")
        guard let currentCustomer = Customer.current else {
            print("No current customer!")
            completion(nil, nil)
            return
        }
        // Params for backend call
        let createKeyParams = [
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
                    print("Get ephemeral key failed")
                    completion(nil, error)
                }
        }
    }
    
    // Creates a new customer and passes ID to callback
    func createCustomer(completion: @escaping (_ success: Bool, _ id: String?) -> Void) {
        let url = self.baseURL.appendingPathComponent("customers").appendingPathComponent("create")
        // Call create stripe customer
        AF.request(url)
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
                }
                // Did not succeed, call completion
                completion(false, nil)
        }
    }
    
    // This is used to compute Stripe cost in cents
    static func getStripeCost(for cost: Double) -> Int {
        return Int(cost*100)
    }
    
}
