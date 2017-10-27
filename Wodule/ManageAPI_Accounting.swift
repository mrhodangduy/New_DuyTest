//
//  ManageAPI_Accounting.swift
//  Wodule
//
//  Created by QTS Coder on 10/24/17.
//  Copyright © 2017 QTS. All rights reserved.
//

import Foundation
import Alamofire


struct ManageAPI_Accounting
{
    
    static func getAccounting(witkToken token: String, completion: @escaping (Bool,NSDictionary?) -> ())
    {
        let url = URL(string: APIURL.accountingURL)
        let httpHeader:HTTPHeaders = ["Authorization":"Bearer \(token)"]

        Alamofire.request(url!, method: .get, parameters: nil, encoding: URLEncoding.default, headers: httpHeader).responseJSON { (response) in
            
            if response.result.isSuccess
            {
                if response.response?.statusCode == 200
                {
                    let json = response.result.value as? NSDictionary
                    completion(true, json?["data"] as? NSDictionary)
                }
                else
                {
                    completion(false, response.result.value as? NSDictionary)
                }
            }
            else
            {
                completion(false, nil)
            }
                        
        }
        
    }
    
    
    
}
