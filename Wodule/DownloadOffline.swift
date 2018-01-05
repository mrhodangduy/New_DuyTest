//
//  DownloadOffline.swift
//  Wodule
//
//  Created by QTS Coder on 12/18/17.
//  Copyright © 2017 QTS. All rights reserved.
//

import UIKit
import Alamofire

class DataOffline
{
    static let shared = DataOffline()
    
    private let sessionManager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 15
        let sessionManager = Alamofire.SessionManager(configuration: configuration)
        return sessionManager
    }()
    
    func download(url: String, folder: String, id: String, saveName: String, completionProgress: @escaping (_ percent: Double) -> (), completion: @escaping (_ status: Bool,_ urlString: String) -> ())
    {
        let downloadUrl = URL(string: url)
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let folder = directoryURL.appendingPathComponent(folder)
            let child = folder.appendingPathComponent(id)
            let file = child.appendingPathComponent(saveName, isDirectory: false)
            return (file, [.createIntermediateDirectories])
        }
        
        sessionManager.download(downloadUrl!, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil, to: destination)
            .downloadProgress { (progress) in
            let qosUtility = DispatchQoS.QoSClass.utility
            DispatchQueue.global(qos: qosUtility).async {
                let percent = progress.fractionCompleted * 100
                completionProgress(percent)
                }
        }
        .response { (response) in
            
            if response.error == nil {
                
                completion(true, (response.destinationURL?.absoluteString)!)
            }
            else {
                completion(false, (response.error?.localizedDescription)!)
            }
        }
    }
    
}
