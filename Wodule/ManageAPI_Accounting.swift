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
    
    static func getAccounting(witkToken token: String,type: String, completion: @escaping (Bool,Int?,NSDictionary?) -> ())
    {
        let url = URL(string: APIURL.baseURL + "/\(type)")
        let httpHeader:HTTPHeaders = ["Authorization":"Bearer \(token)"]
        
        Alamofire.request(url!, method: .get, parameters: nil, encoding: URLEncoding.default, headers: httpHeader).responseJSON { (response) in
            
            if response.result.isSuccess
            {
                if response.response?.statusCode == 200
                {
                    let json = response.result.value as? NSDictionary
                    completion(true,response.response?.statusCode, json?["data"] as? NSDictionary)
                }
                else
                {
                    completion(false,response.response?.statusCode, response.result.value as? NSDictionary)
                }
            }
            else
            {
                completion(false,response.response?.statusCode, response.result.value as? NSDictionary)
            }
                        
        }
        
    }
    
}

struct ManageAPI_Calendar
{
    static func getCalendar(token: String, completion: @escaping (_ status: Bool,_ code: Int, _ results: NSDictionary?) -> ())
    {
        let url = URL(string: APIURL.calendarURL)
        let header: HTTPHeaders = ["Authorization":"Bearer \(token)"]
        
        Alamofire.request(url!, method: .get, parameters: nil, encoding: URLEncoding.default, headers: header).responseJSON { (response) in
            
            if response.result.isSuccess
            {
                if response.response?.statusCode == 200
                {
                    
                    completion(true, 200, response.result.value as? NSDictionary)
                    
                }
                else
                {
                    completion(false, response.response!.statusCode, response.result.value as? NSDictionary)
                }
            }
            else
            {
                completion(false, response.response!.statusCode, response.result.value as? NSDictionary)
            }
            
        }
    }
}
















