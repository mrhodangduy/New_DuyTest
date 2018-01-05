//
//  ManageAPI_ExamOffline.swift
//  Wodule
//
//  Created by QTS Coder on 12/25/17.
//  Copyright © 2017 QTS. All rights reserved.
//

import Foundation
import Alamofire

class ParallelServiceCaller
{
    static let shared = ParallelServiceCaller()
    
    private let sessionManager: SessionManager = {
        
        let config = Alamofire.SessionManager.default.session.configuration
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 15
        let sessionManager = Alamofire.SessionManager(configuration: config)
        return sessionManager
    }()
    
    func startServiceCall(completionHandle: @escaping (_ status: Bool,_ code: Int,_ result: [NSDictionary]?,_ error: NSDictionary?) -> ())
    {
        let token = userDefault.object(forKey: TOKEN_STRING) as! String
        let url = URL(string: APIURL.getAllrecordURL)
        let request = sessionManager.request(url!, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil)
        
        request.responseJSON { (response) in
            
            let json  = response.result.value as? NSDictionary
            if response.result.isSuccess
            {
                if let data = json?["data"] as? [NSDictionary]
                {
                    if !data.isEmpty
                    {
                        print("Fist item", data[0]["identifier"] as! Int)
                        self.registerRecordCall(token: token, data: data[0], completion: { (status, code) in
                            completionHandle(status, code, data, nil)
                        })
                        
                    } else
                    {
                        completionHandle(true, response.response!.statusCode, data, nil)
                    }
                }
            } else {
                completionHandle(false, response.response!.statusCode, nil, json)
            }
        }
    }
    
    private func registerRecordCall(token: String, data: NSDictionary, completion: @escaping (Bool, Int) ->())
    {
        let id = data["identifier"] as! Int
        let url = URL(string: APIURL.getAllrecordURL + "/\(id)")
        let httpHeader:HTTPHeaders = ["Authorization":"Bearer \(token)"]

        let request = sessionManager.request(url!, method: .get, parameters: nil, encoding: URLEncoding.default, headers: httpHeader)
        request.responseJSON { (response) in
            
            print(response.response?.statusCode)
            
            if response.result.isSuccess
            {
                
                print("IDD register:", ((response.result.value as! NSDictionary)["data"] as? NSDictionary)?["identifier"] as? Int)
                completion(true, response.response!.statusCode)

            } else
            {
                completion(false,response.response!.statusCode)
            }
        }
    }
}
    






