//
//  ManageAPI.swift
//  Wodule
//
//  Created by QTS Coder on 10/2/17.
//  Copyright © 2017 QTS. All rights reserved.
//

import Foundation
import Alamofire
import SVProgressHUD


struct CodeType
{
    let id: Int
    let code : String
    let tpye : String
    let organization: String
    let Class: String
    let adviser: String
    
    enum error:Error {
        case missing(String)
    }
    
    init(json:[String: AnyObject]) throws
    {
        guard let code = json["code"] as? String else { throw error.missing("mising")}
        guard let tpye = json["type"] as? String else { throw error.missing("mising")}
        guard let organization = json["organization"] as? String else { throw error.missing("mising")}
        guard let Class = json["class"] as? String else { throw error.missing("mising")}
        guard let adviser = json["adviser"] as? String else { throw error.missing("mising")}
        guard let id = json["id"] as? Int else { throw error.missing("mising")}
        
        self.id = id
        self.code = code
        self.tpye = tpye
        self.organization = organization
        self.Class = Class
        self.adviser = adviser
    }
    
    
    static func getUniqueCodeInfo(code:String, completion: @escaping (CodeType?) -> ())
    {
        let url = URL(string: APIURL.getCodeInfoURL + "/\(code)")
        print(url!)
        
        Alamofire.request(url!, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            
            var result: CodeType?
            
            if response.response?.statusCode == 200
            {
                
                let json = response.result.value as? [[String: AnyObject]]
                
                if json != nil
                {
                    if let data = json?.first
                    {
                        if let code = try? CodeType(json: data)
                        {
                            result = code
                        }
                        else
                        {
                            result = nil
                        }
                        
                    }
                    else
                    {
                        result = nil
                    }
                }
                else
                {
                    result = nil
                }
                
            }
            else
            {
                print(response.response!.statusCode)
                let json = response.result.value as? [String: AnyObject]
                if let error = json?["error"] as? String
                {
                    userDefault.set(error, forKey: NOTIFI_ERROR)
                    userDefault.synchronize()
                }
                result = nil
            }
            
            completion(result)
        }
    }
    
}

struct LoginWithSocial
{
    static let shared = LoginWithSocial()
    
    private let sessionManager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10
        let sessionManager = Alamofire.SessionManager(configuration: configuration)
        return sessionManager
    }()

    func LoginUserWithSocial(username: String, password: String, completion: @escaping (Bool?,Bool?) -> ())
    {
        let url = URL(string: APIURL.loginURL)
        let parameter:Parameters = ["user_name": username, "password": password,"social": "true"]
        let httpHeader: HTTPHeaders = ["Content-Type":"application/x-www-form-urlencoded"]
        
        sessionManager.request(url!, method: HTTPMethod.post, parameters: parameter, encoding: URLEncoding.httpBody, headers: httpHeader).responseJSON(completionHandler: { (response) in
            
            print("\nSTATUS CODE, RESULT", response.response?.statusCode as Any, response.result)
            
            if response.response?.statusCode == 200
            {
                if let json = response.result.value as? [String: AnyObject]
                {
                    print(json)
                    if let token = json["token"] as? String, let first = json["first"] as? Bool
                    {
                        print("TOKEN:\n-------->", token)
                        userDefault.set(token, forKey: TOKEN_STRING)
                        userDefault.synchronize()
                        
                        completion(first, true)
                    }
                    
                }
            }
            else
            {
                completion(nil, false)
            }
            
        })
        
    }
    
    
    func getUserInfoSocial(withToken token: String, completion: @escaping (NSDictionary?) -> ())
    {
        let url  = URL(string: APIURL.getProfileURL)
        let httpHeader: HTTPHeaders = ["Authorization":"Bearer \(token)"]
        
        sessionManager.request(url!, method: HTTPMethod.get, parameters: nil, encoding: URLEncoding.httpBody, headers: httpHeader).responseJSON(completionHandler: { (response) in
            
            var result: NSDictionary?
            
            if response.response?.statusCode == 200
            {
                let json = response.result.value as? [String: AnyObject]
                if let user = json?["user"] as? NSDictionary
                {
                    result = user
                }
                else
                {
                    result = nil
                }
                completion(result)
                
            }
                
            else
            {
                print(response.response!.statusCode)
                completion(nil)
            }
            
        })
        
    }
    
    func updateUserInfoSocial(userID: Int, para: Parameters, completion: @escaping (Bool?, Int?, NSDictionary?) -> ())
    {
        let url = URL(string: APIURL.updateSocialInfoURL + "/\(userID)")
        
        sessionManager.request(url!, method: .post, parameters: para, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            
            let json = response.result.value as? NSDictionary
            
            switch response.response!.statusCode
            {
            case 200:
                
                completion(true, response.response?.statusCode, json)
                
            case 400:
                
                completion(false, response.response?.statusCode, json)
            default:
                
                completion(false, response.response?.statusCode, json)
                
            }
            
        }
    }
    
    
    
}

struct UserInfoAPI
{
    
    static let shared = UserInfoAPI()
    
    private let sessionManager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 15
        let sessionManager = Alamofire.SessionManager(configuration: configuration)
        return sessionManager
    }()
    
    func getUserInfo(withToken token: String,completion: @escaping (NSDictionary?) -> ())
    {
        let url  = URL(string: APIURL.getProfileURL)
        let httpHeader: HTTPHeaders = ["Authorization":"Bearer \(token)"]
        
        sessionManager.request(url!, method: HTTPMethod.get, parameters: nil, encoding: URLEncoding.httpBody, headers: httpHeader).responseJSON(completionHandler: { (response) in
            
            var result: NSDictionary?
            
            if response.response?.statusCode == 200
            {
                let json = response.result.value as? NSDictionary
                if let user = json?["user"] as? NSDictionary
                {
                    result = user
                    
                }
                else
                {
                    result = nil
                }
                completion(result)
                
            }
            
        })
        
    }
    
    func LoginUser(username: String, password: String, completion: @escaping (Bool?) -> ())
    {
        let url = URL(string: APIURL.loginURL)
        let parameter:Parameters = ["user_name": username, "password": password]
        let httpHeader: HTTPHeaders = ["Content-Type":"application/x-www-form-urlencoded"]
        
        sessionManager.request(url!, method: HTTPMethod.post, parameters: parameter, encoding: URLEncoding.httpBody, headers: httpHeader).responseJSON(completionHandler: { (response) in
            
            var status:Bool?
            
            print("\n STATUS CODE, RESULT", response.response!.statusCode, response.result.description)
            
            if response.response?.statusCode == 200
            {
                if let json = response.result.value as? [String: String]
                {
                    if let token = json["token"]
                    {
                        status = true
                        print("TOKEN:\n -------->", token)
                        userDefault.set(token, forKey: TOKEN_STRING)
                        userDefault.synchronize()
                        
                    }                    
                }
            }
            else
            {
                status = false
            }
            completion(status)
        })
        
    }
    
    func RegisterUser(para: Parameters,  completion: @escaping (Bool) -> ())
    {
        let url = URL(string: APIURL.registerURL)
        
        sessionManager.upload(multipartFormData: { (data) in
            
            for (key, value) in para {
                data.append((value as! String).data(using: String.Encoding.utf8)!, withName: key)
                
            }
            
        }, usingThreshold: 1, to: url!, method: HTTPMethod.post, headers: nil) { (result) in
            
            switch result
            {
            case .success(request: let upload, streamingFromDisk: _, streamFileURL: _):
                upload.uploadProgress(closure: { (progress) in
                    
                    print("PROGRESS:->",progress.fractionCompleted)
                    
                })
                
                upload.responseJSON(completionHandler: { (response) in
                    
                    if response.result.isSuccess
                    {
                        let json = response.result.value as? [String:AnyObject]
                        print("\nJSON DATA:\n---->", json as Any)
                        
                        
                        if let token = json?["token"] as? String
                        {
                            
                            userDefault.set(token, forKey: TOKEN_STRING)
                            userDefault.synchronize()
                            completion(true)
                            
                        }
                        else if let error = json?["error"] as? String
                        {
                            print("\nERROR MESSAGE:------>" ,error)
                            userDefault.set(error, forKey: NOTIFI_ERROR)
                            userDefault.synchronize()
                            completion(false)
                        }
                        else
                        {
                            if response.description.contains("Invalid code")
                            {
                                userDefault.set("Invalid code", forKey: NOTIFI_ERROR)
                                userDefault.synchronize()
                                completion(false)
                            }
                            
                        }
                    }
                    else
                    {
                        completion(false)
                        let errorString = "Failure while requesting your infomation. Please try again."
                        userDefault.set(errorString, forKey: NOTIFI_ERROR)
                        userDefault.synchronize()
                    }
                    
                })
                
            case .failure(let error):
                print(error.localizedDescription)
                let errorString = "Failure while requesting your infomation. Please try again."
                userDefault.set(errorString, forKey: NOTIFI_ERROR)
                userDefault.synchronize()
                completion(false)
                
            }
            
        }
    }
    
    
    func updateUserProfile(para: Parameters,header: HTTPHeaders,picture: Data?, completion: @escaping (Bool,Int?,NSDictionary?) -> ())
    {
        let url = URL(string: APIURL.updateProfileURL)
        
        sessionManager.upload(multipartFormData: { (data) in
            
            
            let dateformat = DateFormatter()
            dateformat.dateFormat = "MM_DD_YY_hh_mm_ss"
            
            if let imageData = picture
            {
                data.append(imageData, withName: "picture", fileName: dateformat.string(from: Date()) + ".jpg", mimeType: "image/jpg")
            }
                
            else{
                print("\nPICTURE DATA:------>", picture as Any)
            }

            for (key, value) in para {
                
                data.append((value as! String).data(using: String.Encoding.utf8)!, withName: key)
                
            }
            
        }, usingThreshold: 1, to: url!, method: HTTPMethod.post, headers: header) { (result) in
            
            switch result
            {
            case .success(request: let upload, streamingFromDisk: _, streamFileURL: _):
                
                upload.uploadProgress(closure: { (progress) in
                    
                    print("PROGRESS:->",progress.fractionCompleted)
                    
                })
                
                upload.responseJSON(completionHandler: { (response) in
                    
                    guard let json = response.result.value as? NSDictionary else { return }
                    
                    print(response.result)
                    print(json)
                    if response.response?.statusCode == 200
                    {
                        completion(true, response.response?.statusCode, json)
                    }
                    else
                    {
                        completion(false, response.response?.statusCode, json)
                    }
                    
                })
                
                
            case . failure(let error):
                print(error.localizedDescription)
                completion(false, nil, nil)
            }
            
            
        }
    }
    
    func ResetPassword(email: String, completion: @escaping (Bool?, NSDictionary?)->())
    {
        let url = URL(string: "http://wodule.io/api/password/email")
        
        let para:Parameters = ["email": email]
        let header: HTTPHeaders = ["Accept": "application/json"]
        
        sessionManager.request(url!, method: .post, parameters: para, encoding: URLEncoding.default, headers: header).responseJSON { (response) in
            
            let json = response.result.value as? NSDictionary
            let code = response.response?.statusCode
            
            if response.result.isSuccess
            {
                if code == 200
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
        }
    }
    
    
    func invalidToken(token: String, completion: @escaping (_ status: Bool, _ result: NSDictionary?)->())
    {
        let url = URL(string: APIURL.invalidTokenURL)
        let httpHeader: HTTPHeaders = ["Authorization":"Bearer \(token)"]
        
        sessionManager.request(url!, method: .get, parameters: nil, encoding: URLEncoding.default, headers: httpHeader).responseJSON { (response) in
            
            if response.result.isSuccess && response.response?.statusCode == 200 {
                completion(true, response.result.value as? NSDictionary)
            } else {
                completion(false, response.result.value as? NSDictionary)
            }            
        }
    }
    
    func getMessage(completion: @escaping (_ status: Bool,_ code: Int,_ results:NSDictionary?,_ otalPage:Int?) -> ())
    {
        let url = URL(string: APIURL.messageURL)
        let token = userDefault.object(forKey: TOKEN_STRING) as! String
        let httpHeader: HTTPHeaders = ["Authorization":"Bearer \(token)"]
        print(token)
        
        sessionManager.request(url!, method: .get, parameters: nil, encoding: URLEncoding.default, headers: httpHeader).responseJSON { (response) in
            
            if response.result.isSuccess
            {
                if response.response?.statusCode == 200
                {
                    let json = response.result.value as? NSDictionary
                    if let data = json?["data"] as? [NSDictionary]
                    {
                        if data.count > 0
                        {
                            guard let meta = json?["meta"] as? NSDictionary, let pagination = meta["pagination"] as? NSDictionary, let total_pages = pagination["total_pages"] as? Int else {return}
                            completion(true, 200, json, total_pages)

                        }
                        else
                        {
                            completion(true, 200, json, 1)
                        }
                    }
                }
                else
                {
                    completion(false, (response.response?.statusCode)!, response.result.value as? NSDictionary,1)
                }
            }
            else
            {
                completion(false, (response.response?.statusCode)!, response.result.value as? NSDictionary,1)
            }
            
        }

    }
    
    func readMessage(withToken token: String, identifier: Int, completion: @escaping (Bool, Int, NSDictionary?) -> ())
    {
        let url = URL(string: APIURL.messageURL + "/\(identifier)")
        let httpHeader: HTTPHeaders = ["Authorization":"Bearer \(token)"]

        sessionManager.request(url!, method: .get, parameters: nil, encoding: URLEncoding.default, headers: httpHeader).responseJSON { (response) in
            
            if response.result.isSuccess
            {
                if response.response?.statusCode == 200
                {
                    completion(true,200, response.result.value as? NSDictionary)
                }
                else
                {
                    completion(false, response.response!.statusCode, response.result.value as? NSDictionary)
                }
            }
            else
            {
                completion(false, response.response!.statusCode, nil)
            }
            
        }
    }
    
}

struct Categories
{
    static let shared = Categories()
    
    private let sessionManager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 15
        let sessionManager = Alamofire.SessionManager(configuration: configuration)
        return sessionManager
    }()
    
    func getCategory(completion: @escaping (Bool,NSDictionary?) -> ())
    {
        let url = URL(string: APIURL.categoriesURL)
        
        sessionManager.request(url!, method: HTTPMethod.get, parameters: nil, encoding: URLEncoding.httpBody, headers: nil).responseJSON { (response) in
            
            print("RESPONSE:---->\n",response.description)
            print("RESPONSE:---->\n",(response.response?.statusCode)!)
            
            if response.response?.statusCode == 200
            {
                
                completion(true, response.result.value as? NSDictionary)
            
            }
            else
            {
                
                completion(false,response.result.value as? NSDictionary)
                
            }
            
            
        }
    }
    
}

struct CategoriesExam
{
    let number:Int
    let identifier:Int
    let questioner: String?
    let photo:String?
    let detail: String
    let score: Int
    let subject: Int
    let admin: Int
    let creationDate: String
    let lastChange: String
    
    enum error:Error {
        case missing(String)
    }
    
    init(json: [String: AnyObject],questioner:String?, photo: String? ) throws {
        
        guard let number = json["number"] as? Int else { throw error.missing("missing value") }
        guard let identifier = json["identifier"] as? Int else { throw error.missing("missing value") }
        guard let detail = json["detail"] as? String else { throw error.missing("missing value") }
        guard let score = json["score"] as? Int else { throw error.missing("missing value") }
        guard let subject = json["subject"] as? Int else { throw error.missing("missing value") }
        guard let admin = json["admin"] as? Int else { throw error.missing("missing value") }
        guard let creationDate = json["creationDate"] as? String else { throw error.missing("missing value") }
        guard let lastChange = json["lastChange"] as? String else { throw error.missing("missing value") }
        
        self.number = number
        self.identifier = identifier
        self.questioner = questioner
        self.photo = photo
        self.detail = detail
        self.score = score
        self.subject = subject
        self.admin = admin
        self.creationDate = creationDate
        self.lastChange = lastChange
        
    }
    
    static func getExam(categoryID: Int, completion: @escaping ([CategoriesExam]?) -> ())
    {
        let url = URL(string: "http://wodule.io/api/category/\(categoryID)/exams")
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 15
        let sessionManager = Alamofire.SessionManager(configuration: configuration)

        sessionManager.request(url!, method: HTTPMethod.get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            
            var result = [CategoriesExam]()
            
            print((response.response?.description)!)
            
            let json = response.result.value as? [String: AnyObject]
            if response.response?.statusCode == 200
            {
                if let jsonData  = json?["data"] as? [[String: AnyObject]]
                {
                    for item in jsonData
                    {
                        let questioner = item["questioner"] as? String ?? nil
                        let photo = item["photo"] as? String ?? nil
                        if let exam = try? CategoriesExam(json: item, questioner: questioner, photo: photo)
                        {
                            result.append(exam)
                        }
                        else
                        {
                            result = []
                        }
                    }
                }
            }
            else
            {
                if let errorCode = json?["code"] as? Int
                {
                    userDefault.set(errorCode, forKey: NOTIFI_ERROR)
                    userDefault.synchronize()
                }
                result = []
            }
            
            completion(result)
            
        }
    }
    
}

struct AssesmentHistory
{
    
    static let shared = AssesmentHistory()
    
    private let sessionManager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10
        let sessionManager = Alamofire.SessionManager(configuration: configuration)
        return sessionManager
    }()
    func getUserHistory(type: String, withToken token: String, userID: Int,page: Int, completion: @escaping (Bool?,_ code:Int?,AnyObject?,[NSDictionary]?,Int) -> ())
    {
        let url = URL(string: "http://wodule.io/api/users/\(userID)/\(type)?page=\(page)")
        let httpHeader:HTTPHeaders = ["Authorization":"Bearer \(token)"]
        
        sessionManager.request(url!, method: HTTPMethod.get, parameters: nil, encoding: URLEncoding.httpBody, headers: httpHeader).responseJSON { (response) in
            
            if response.response?.statusCode == 200
            {
                let json = response.result.value as? NSDictionary
                print("JSON",json as Any)
                if let data = json?["data"] as? [NSDictionary]
                {
                    print("DATA",data)
                    if data.count != 0
                    {
                        guard let meta = json?["meta"] as? NSDictionary, let pagination = meta["pagination"] as? NSDictionary, let total_pages = pagination["total_pages"] as? Int else {return}
                        
                        completion(true,response.response?.statusCode,nil, data, total_pages)
                    }
                    else
                    {
                        completion(true,response.response?.statusCode,nil, data, 1)
                    }
                    
                }
                else
                {
                    completion(false,response.response?.statusCode,response.result.value as? NSDictionary , nil, 1)
                }
            }
            
            else
            {
                completion(false,response.response?.statusCode,response.result.value as? NSDictionary, nil, 1)
                
            }
            
        }
        
    }
    
}





















