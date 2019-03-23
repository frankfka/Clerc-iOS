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
    
    static let sharedClient = StripeService()
    var baseURLString: String? = nil
    var baseURL: URL {
        if let urlString = self.baseURLString, let url = URL(string: urlString) {
            return url
        } else {
            fatalError()
        }
    }
    
    func completeCharge(_ result: STPPaymentResult,
                        amount: Int,
                        shippingAddress: STPAddress?,
                        shippingMethod: PKShippingMethod?,
                        completion: @escaping STPErrorBlock) {
        let url = self.baseURL.appendingPathComponent("charge")
        var params: [String: Any] = [
            "source": result.source.stripeID,
            "amount": amount,
            "metadata": [
                // example-ios-backend allows passing metadata through to Stripe
                "charge_request_id": "B3E611D1-5FA1-4410-9CEC-00958A5126CB",
            ],
            ]
        params["shipping"] = STPAddress.shippingInfoForCharge(with: shippingAddress, shippingMethod: shippingMethod)
        AF.request(url, method: .post, parameters: params)
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
    
    func createCustomerKey(withAPIVersion apiVersion: String, completion: @escaping STPJSONResponseCompletionBlock) {
        let url = "http://34.217.14.89:4567/customers/create-ephemeral-key"//self.baseURL.appendingPathComponent("ephemeral_keys")
        print("Getting ephemeral key with API Version: \(apiVersion)")
        guard let currentCustomer = Customer.current else {
            print("No current customer!")
            completion(nil, nil)
            return
        }
        AF.request(url, method: .post, parameters: [
            "stripe_version": apiVersion,
            "customer": currentCustomer.stripeId
            ])
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
        // Call create stripe customer
        AF.request("http://34.217.14.89:4567/customers/create")
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
