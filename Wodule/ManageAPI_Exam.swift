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
    static func uploadExam(withToken token:String, idExam: Int, audiofile1: Data?,audiofile2: Data?,audiofile3: Data?,audiofile4: Data?, completion: @escaping (Bool?, NSDictionary?) -> ())
    {
        let url = URL(string: "http://wodule.io/api/exams/\(idExam)/records")
        print(url)
        
        let httpHeader:HTTPHeaders = ["Authorization":"Bearer \(token)"]
        
        Alamofire.upload(multipartFormData: { (data) in
            
            
            if let audioURL1 = audiofile1
            {
                print("\n\nAUDIODATA1-->",audioURL1)
                data.append(audioURL1, withName: "audio_1", fileName: "upload1.mp3", mimeType: "audio/mpeg")
            }
            if let audioURL2 = audiofile2
            {
                print("\n\nAUDIODATA2-->",audioURL2)
                data.append(audioURL2, withName: "audio_2", fileName: "upload2.mp3", mimeType: "audio/mpeg")
            }
            if let audioURL3 = audiofile3
            {
                print("\n\nAUDIODATA3-->",audioURL3)
                data.append(audioURL3, withName: "audio_3", fileName: "upload3.mp3", mimeType: "audio/mpeg")
            }
            if let audioURL4 = audiofile4
            {
                print("\n\nAUDIODATA4-->",audioURL4)
                data.append(audioURL4, withName: "audio_4", fileName: "upload4.mp3", mimeType: "audio/mpeg")
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
    
    static func getAllRecord(page: Int, completion: @escaping ([NSDictionary]?, _ totalPage: Int?,_ code: Int? ,NSDictionary?) -> ())
    {
        let url = URL(string: APIURL.getAllrecordURL + "\(page)")
        
        Alamofire.request(url!, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            
            let json = response.result.value as? NSDictionary
            let code = response.response?.statusCode as? Int
            
            if response.result.isSuccess
            {
                
                if let data = json?["data"] as? [NSDictionary]
                {
                    guard let meta = json?["meta"] as? NSDictionary, let pagination = meta["pagination"] as? NSDictionary, let total_pages = pagination["total_pages"] as? Int else {return}
                    
                    completion(data, total_pages,code,json)
                    
                }
                else
                {
                    if let error = json?["error"] as? String
                    {
                        
                        print(error, json?["code"] as! Int)
                        completion(nil, nil,code, json)
                    }
                    
                    
                }
            }
            else
            {
                completion(nil, nil,code,json)
            }
            
        }
        
    }
    
    static func postGrade(withToken token: String, identifier:Int, grade1: Int,comment1:String, grade2: Int, comment2:String, grade3: Int?,comment3:String?,grade4: Int?,comment4:String?, completion: @escaping (Bool?, Int?, NSDictionary?) -> ())
    {
        let url = URL(string: APIURL.baseURL + "/records/" + "\(identifier)" + "/grades")
        let httpHeader:HTTPHeaders = ["Authorization":"Bearer \(token)", "Content-Type": "application/x-www-form-urlencoded"]
        var para: Parameters = ["grade_1": "\(grade1)","comment_1": comment1,
                                "grade_2": "\(grade2)","comment_2": comment2
        ]
        if let grade_3 = grade3
        {
            para.updateValue("\(grade_3)", forKey: "grade_3")
            para.updateValue(comment3!, forKey: "comment_3")
        }
        if let grade_4 = grade4
        {
            para.updateValue("\(grade_4)", forKey: "grade_4")
            para.updateValue(comment4!, forKey: "comment_4")
        }
        
        Alamofire.request(url!, method: .post, parameters: para, encoding: URLEncoding.default, headers: httpHeader).responseJSON { (response) in
            
            let json = response.result.value as? NSDictionary
            let code = response.response!.statusCode
            
            if response.result.isSuccess
            {
                if response.response?.statusCode == 200
                {
                    completion(true, code, json)
                }
                else
                    
                {
                    completion(false, code, json)
                }
            }
            else
            {
                completion(false, code, json)
                print(response.result.error?.localizedDescription)
                
            }
            
        }
        
    }
    
}

