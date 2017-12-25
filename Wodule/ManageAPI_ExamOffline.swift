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
    
    func startServiceCall(completionHandle: @escaping (_ status: Bool,_ code: Int,_ result: [NSDictionary]?,_ error: NSDictionary?) -> ())
    {
        let token = userDefault.object(forKey: TOKEN_STRING) as! String
        let url = URL(string: APIURL.getAllrecordURL)
        let request = Alamofire.request(url!, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil)
        
        request.responseJSON { (response) in
            
            let json  = response.result.value as? NSDictionary
            let code = response.response!.statusCode
            if response.result.isSuccess
            {
                if let data = json?["data"] as? [NSDictionary]
                {
                    if !data.isEmpty
                    {
                        print("Fist item", data[0]["identifier"] as! Int)
                        self.registerRecordCall(token: token, data: data[0], completion: { (status) in
                            
                            completionHandle(status, code, data, nil)
                            
                        })
                        
                    } else
                    {
                        completionHandle(true, code, data, nil)
                    }
                }
                
            } else {
                completionHandle(false, code, nil, json)
            }
        }
        
    }
    
    private func registerRecordCall(token: String, data: NSDictionary, completion: @escaping (Bool) ->())
    {
        let id = data["identifier"] as! Int
        let url = URL(string: APIURL.getAllrecordURL + "/\(id)")
        let httpHeader:HTTPHeaders = ["Authorization":"Bearer \(token)"]

        let request = Alamofire.request(url!, method: .get, parameters: nil, encoding: URLEncoding.default, headers: httpHeader)
        request.responseJSON { (response) in
            
            if response.result.isSuccess
            {
                completion(true)
                print("IDD register:", ((response.result.value as! NSDictionary)["data"] as? NSDictionary)?["identifier"] as! Int)
                
            } else
            {
                completion(false)
            }
        }
    }
}
    






