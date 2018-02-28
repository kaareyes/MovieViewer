//
//  WebServiceAPI.swift
//  MoviewViewer
//
//  Created by Amiel Reyes on 2/28/18.
//  Copyright © 2018 Amiel Reyes. All rights reserved.
//

import Foundation
import Alamofire

class WebServiceAPI {
    
    typealias newParameter = [Parameters]
    
    /**
     * Singleton shared instance
     */
    static let shared = WebServiceAPI()
    
    /**
     * Prevent misuse and new instance creation
     */
    private
    init() {
        
    }
    
    // MARK: - Properties
    
    typealias Completion = (_ responseObject: [String: Any]?, _ error: Error?) -> Void

    
    // MARK: - GET
    
    func getRequest(
        _ url: String,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: HTTPHeaders? = nil, completion: Completion?) {
        
        let newURL = kbaseURL + url
        print(newURL)
        Alamofire.request(newURL, method: .get, parameters: parameters, encoding: encoding, headers: headers)
            .responseJSON { (dataResponse) in
                if dataResponse.result.isSuccess, let responsObject = dataResponse.result.value as? [String: Any] {
                    completion?(responsObject, nil)
                }else{
                    completion?(nil, dataResponse.result.error)
                }
        }
    }
}


