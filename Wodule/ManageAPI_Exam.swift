//
//  ManageAPI_Exam.swift
//  Wodule
//
//  Created by QTS Coder on 10/10/17.
//  Copyright © 2017 QTS. All rights reserved.
//

import Foundation
import Alamofire


struct ExamRecord
{
    static func uploadExam(withToken token:String, idExam: Int, audiofile: Data?, completion: @escaping (Bool?, NSDictionary?) -> ())
    {
        let url = URL(string: "http://wodule.io/api/exams/\(idExam)/records")
        
        let httpHeader:HTTPHeaders = ["Authorization":"Bearer \(token)"]
        
        Alamofire.upload(multipartFormData: { (data) in
            
            
            if let audioURL = audiofile
            {
                print("\n\nAUDIODATA-->",audioURL)
                data.append(audioURL, withName: "audio", fileName: "upload.m4a", mimeType: "audio/m4a")
                print(data.boundary)
            }
            else
            {
                completion(false, nil)
            }
            
            
        }, usingThreshold: 1, to: url!, method: .post, headers: httpHeader) { (results) in
            
            switch results
            {
            case .failure(let error):
                print(error.localizedDescription)
                let errorString = "Failure while requesting your infomation. Please try again."
                userDefault.set(errorString, forKey: NOTIFI_ERROR)
                userDefault.synchronize()
                completion(false, nil)
                
            case .success(request: let upload, streamingFromDisk: _, streamFileURL: _):
                
                upload.uploadProgress(closure: { (progress) in
                    print("PROGRESS UPLOAD:--->", (progress.fractionCompleted * 100))
                    
                })
                
                upload.responseJSON(completionHandler: { (response) in
                    
                    guard let json = response.result.value as? NSDictionary else {return}
                    print(json)
                    
                    if response.result.isSuccess
                    {
                        if response.response?.statusCode == 200
                        {
                            completion(true, json)
                        }
                        else
                        {
                            completion(false, json)
                        }
                    }
                    else
                    {
                        completion(false, json)
                    }
                    
                })
            }
            
            
        }
        
    }
    
    static func getAllRecord(page: Int, completion: @escaping ([NSDictionary]?, _ totalPage: Int?, NSDictionary?) -> ())
    {
        let url = URL(string: APIURL.getAllrecordURL + "\(page)")
        let header: HTTPHeaders = ["Retry-After": "3600"]
        
        Alamofire.request(url!, method: .get, parameters: nil, encoding: URLEncoding.default, headers: header).responseJSON { (response) in
            
            let json = response.result.value as? NSDictionary
            
            if response.result.isSuccess
            {
                
                if let data = json?["data"] as? [NSDictionary]
                {
                    guard let meta = json?["meta"] as? NSDictionary, let pagination = meta["pagination"] as? NSDictionary, let total_pages = pagination["total_pages"] as? Int else {return}
                    
                    completion(data, total_pages,json)
                    
                }
                else
                {
                    if let error = json?["error"] as? String
                    {
                        
                        print(error, json?["code"] as! Int)
                        completion(nil, nil,json)
                    }
                    
                    
                }
            }
            else
            {
                completion(nil, nil,json)
            }

        }
        
    }
    
    static func postGrade(withToken token: String, identifier:Int, grade: Int,comment:String, completion: @escaping (Bool?, Int?, NSDictionary?) -> ())
    {
        let url = URL(string: APIURL.baseURL + "/records/" + "\(identifier)" + "/grades")
        let httpHeader:HTTPHeaders = ["Authorization":"Bearer \(token)"]
        let para: Parameters = ["grade": "\(grade)",
            "comment": comment]
        
        Alamofire.request(url!, method: .post, parameters: para, encoding: URLEncoding.default, headers: httpHeader).response { (response) in
            
            print(response.response?.statusCode)
            
            
        }
        
        
//        Alamofire.request(url!, method: .post, parameters: para, encoding: URLEncoding.httpBody, headers: httpHeader).responseJSON { (response) in
//            
//            let json = response.result.value as? Any
//            print(response.response?.statusCode)
//            let code = response.response!.statusCode
//            
//            if response.result.isSuccess
//            {
//                if response.response?.statusCode == 200
//                {
//                    completion(true, code, json as! NSDictionary)
//                }
//                else
//                    
//                {
//                    completion(false, code, json as! NSDictionary)
//                }
//            }
//            else
//            {
//                completion(false, code, json as! NSDictionary)
//            }
        
        }
        
    }
    

