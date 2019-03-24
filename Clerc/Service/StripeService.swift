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
    func completeCharge(_ result: STPPaymentResult, amount: Int, completion: @escaping STPErrorBlock) {
        // Check that current customer exists
        guard let currentCustomer = Customer.current else {
            // TODO this does nothing, but we would want to throw some sort of error
            print("No current customer!")
            return
        }
        let url = self.baseURL.appendingPathComponent("charge")
        // TODO:  finalize these parameters
        let chargeParams: [String: Any] = [
            "customer_id": currentCustomer.stripeID,
            "amount": amount,
            "source": result.source.stripeID,
            "CONNECTED_STRIPE_ACCOUNT_ID": "acct_1EALLCF8Tv70HUia"// For testing ONLY
            ]
        AF.request(url, method: .post, parameters: chargeParams, encoding: JSONEncoding.default)
            .validate(statusCode: 200..<300)
            .responseString { response in
                switch response.result {
                case .success:
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
            .responseString { response in
                //TODO make endpoint return json!
                switch response.result {
                case .success(_):
                    if let custId = response.result.value {
                        // Call completion and return
                        completion(true, custId)
                        return
                    }
                case .failure(_):
                    print("Make customer endpoint errored")
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
