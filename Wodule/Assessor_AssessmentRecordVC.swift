//
//  Assessor_AssessmentRecordVC.swift
//  Wodule
//
//  Created by QTS Coder on 12/8/17.
//  Copyright © 2017 QTS. All rights reserved.
//

import UIKit
import SQLite

class Assessor_AssessmentRecordVC: UIViewController {
    @IBOutlet weak var recordsTableView: UITableView!
    
    var recordList: [ExamDataStruct] = []
    let token = userDefault.object(forKey: TOKEN_STRING) as? String
    var assessorID: Int64!
    
    var currentpage:Int!
    var totalPage:Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recordsTableView.dataSource = self
        recordsTableView.delegate = self
        recordsTableView.register(UINib(nibName: "AssessmentRecordCell", bundle: nil), forCellReuseIdentifier: "AssessmentRecordCell")

        downloadExam()
        
        let data = DatabaseManagement.shared.queryAllExam()
        
        for item in data
        {
            print("#######")
            print(item.description)
        }
        
        
        
        
    }
    @IBAction func onClickRefresh(_ sender: Any) {
        onHandleCallAPI()        
    }

    @IBAction func onClickBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func downloadExam()
    {
        if Connectivity.isConnectedToInternet
        {
            self.loadingShow()
            currentpage = 1
            ExamRecord.downloadRecord(token: self.token!, page: self.currentpage, completion: { (status, code, result, total_Page) in
                if status == true && (result?.count)! > 0 {
                    self.totalPage = total_Page
                    self.onHandleSaveDataToLocal(data: result!, examinerId: self.assessorID)
                    DispatchQueue.main.async {
                        self.recordList = DatabaseManagement.shared.queryAllExam(withID: self.assessorID, status: "pending")
                        self.recordsTableView.reloadData()
                        self.loadingHide()
                    }
                } else {
                    self.loadingHide()
                    self.recordList = DatabaseManagement.shared.queryAllExam(withID: self.assessorID, status: "pending")
                    DispatchQueue.main.async {
                        self.recordsTableView.reloadData()
                    }
                }
            })
        }
        else {
            self.recordList = DatabaseManagement.shared.queryAllExam(withID: self.assessorID, status: "pending")
            DispatchQueue.main.async {
                self.recordsTableView.reloadData()
            }
        }
        
    }
    
    func onHandleSaveDataToLocal(data: [NSDictionary], examinerId: Int64)
    {
        if data.count > 0
        {
            for examItem in data {
                let identifier = examItem["identifier"] as! Int64
                let examName = examItem["exam"] as! String
                let examQuestionaireOne = examItem["examQuestionaireOne"] as? String
                let examQuestionaireTwo = examItem["examQuestionaireTwo"] as? String
                let examQuestionaireThree = examItem["examQuestionaireThree"] as? String
                let examQuestionaireFour = examItem["examQuestionaireFour"] as? String
                let audio_1 = examItem["audio_1"] as? String
                let audio_2 = examItem["audio_2"] as? String
                let audio_3 = examItem["audio_3"] as? String
                let audio_4 = examItem["audio_4"] as? String
                let comment_1 = examItem["comment_1"] as? String
                let comment_2 = examItem["comment_2"] as? String
                let comment_3 = examItem["comment_3"] as? String
                let comment_4 = examItem["comment_4"] as? String
                let score_1 = examItem["score_1"] as? String
                let score_2 = examItem["score_2"] as? String
                let score_3 = examItem["score_3"] as? String
                let score_4 = examItem["score_4"] as? String
                let status = examItem["status"] as! String
                let lastChange = examItem["lastChange"] as! String
                if status == "graded"
                {
                    return
                }
                let ids:[Int64] = DatabaseManagement.shared.queryIdentifierListAll()
                if ids.contains(identifier)
                {
                    print("Already exist")
                    let idsList = DatabaseManagement.shared.queryIdentifiersNotDownloadAudio(of: self.assessorID)
                    print(idsList)
                    
                    if idsList.contains(identifier)
                    {
                        if audio_3 != nil {
                            let audiolist = [audio_1, audio_2, audio_3, audio_4]
                            for i in 0...3 {
                                DataOffline.shared.download(url: audiolist[i]!, folder: "\(self.assessorID!)", id: "\(identifier)", saveName: "audio_\(i+1)", completion: { (status, urlString) in
                                    if status && i == 3 {
                                        
                                        let updateid = DatabaseManagement.shared.updateExamDownload(id: identifier, isDownloaded: true)
                                        print(updateid)
                                    }
                                })
                            }
                        } else {
                            let audiolist = [audio_1, audio_2]
                            for i in 0...1 {
                                DataOffline.shared.download(url: audiolist[i]!, folder: "\(self.assessorID!)", id: "\(identifier)", saveName: "audio_\(i+1)", completion: { (status, urlString) in
                                    if status && i == 1 {
                                        
                                        let updateid = DatabaseManagement.shared.updateExamDownload(id: identifier, isDownloaded: true)
                                        print(updateid)
                                    }
                                })
                            }
                        }
                    } else
                    {
                        print("Downloaded")
                    }
                    
                } else {
                    let insertID = DatabaseManagement.shared.addExam(identifier: identifier, examinerId: examinerId, examName: examName, status: status, examQuestionaireOne: examQuestionaireOne, examQuestionaireTwo: examQuestionaireTwo, examQuestionaireThree: examQuestionaireThree, examQuestionaireFour: examQuestionaireFour, comment_1: comment_1, comment_2: comment_2, comment_3: comment_3, comment_4: comment_4, score_1: score_1, score_2: score_2, score_3: score_3, score_4: score_4, audio_1: audio_1, audio_2: audio_2, audio_3: audio_3, audio_4: audio_4, lastChange: lastChange, isDownload: false)
                    print(insertID as Any)
                    if insertID != nil
                    {
                        self.loadingShow()
                        if audio_3 != nil {
                            let audiolist = [audio_1, audio_2, audio_3, audio_4]
                            for i in 0...3 {
                                DataOffline.shared.download(url: audiolist[i]!, folder: "\(self.assessorID!)", id: "\(identifier)", saveName: "audio_\(i+1)", completion: { (status, urlString) in
                                    if status && i == 3 {
                                        
                                        let updateid = DatabaseManagement.shared.updateExamDownload(id: identifier, isDownloaded: true)
                                        print(updateid)
                                        
                                    }
                                })
                                
                            }
                            DispatchQueue.main.async(execute: { 
                                self.loadingHide()
                            })
                        } else {
                            let audiolist = [audio_1, audio_2]
                            for i in 0...1 {
                                DataOffline.shared.download(url: audiolist[i]!, folder: "\(self.assessorID!)", id: "\(identifier)", saveName: "audio_\(i+1)", completion: { (status, urlString) in
                                    if status && i == 1 {
                                        
                                        let updateid = DatabaseManagement.shared.updateExamDownload(id: identifier, isDownloaded: true)
                                        print(updateid)
                                    }
                                    
                                })
                            }
                            DispatchQueue.main.async(execute: {
                                self.loadingHide()
                            })
                        }
                    }
                }
            }
        }
        
    }

    func onHandleCallAPI()
    {
        if Connectivity.isConnectedToInternet
        {
            self.loadingShow()
            ExamRecord.getAllRecord(completion: { (records: [NSDictionary]?, code: Int?, error: NSDictionary?) in
                print(records as Any)
                
                if let exams = records
                {
                    let id = exams[0]["identifier"] as! Int
                    ExamRecord.getUniqueRecord(token: self.token!, id: id)
                    
                    DispatchQueue.main.async(execute: {
                        self.downloadExam()
                        self.loadingHide()
                    })

                    
                } else if code == 200
                {
                    DispatchQueue.main.async {
                        self.loadingHide()
                        self.alertMissingText(mess: "No exam to download.", textField: nil)
                    }
                } else if error?["code"] as! Int == 429
                {
                    if let errorMess = (error?["error"] as? String)
                    {
                        DispatchQueue.main.async(execute: {
                            self.loadingHide()
                            self.alertMissingText(mess: "\(errorMess)\n(ErrorCode:\(error?["code"] as! Int))", textField: nil)
                        })
                    } else {
                        DispatchQueue.main.async(execute: {
                            self.loadingHide()
                            self.alertMissingText(mess: "Server error. Try again later.", textField: nil)
                        })
                        
                    }
                }
                else if code == 401
                {
                    if let error = error?["error"] as? String
                    {
                        if error.contains("Token")
                        {
                            self.loadingHide()
                            self.onHandleTokenInvalidAlert()
                        }
                    }
                }
            })
        }
        else
        {
            self.displayAlertNetWorkNotAvailable()
        }

    }
    
    func deleteAudioFile(fileName: String, examninerID: Int64) {
        let fileManager = FileManager.default
        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        guard let dirPath = paths.first else {
            return
        }
        let filePath = "\(dirPath)/\(examninerID)/" + fileName
        do {
            try fileManager.removeItem(atPath: filePath)
            print("deleted")
        } catch let error as NSError {
            print(error.debugDescription)
        }
    }
    
}

extension Assessor_AssessmentRecordVC: UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AssessmentRecordCell", for: indexPath) as! AssessmentRecordCell
        cell.selectionStyle = .none
        cell.delegate = self
        cell.indexPath = indexPath
        cell.examIDLabel.text = recordList[indexPath.row].examName
        if recordList[indexPath.row].isDownloaded == true
        {
            cell.startButton.isHidden = false
        }
       
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastItem = recordList.count - 2
        if indexPath.row == lastItem && currentpage < totalPage + 1
        {
            currentpage = currentpage + 1
            loadmore(page: currentpage)
            print(currentpage)
        }
        
        print("No loadmore",currentpage,totalPage)

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(recordList[indexPath.row])
        
    }
    
    func loadmore(page:Int)
    {
        ExamRecord.downloadRecord(token: self.token!, page: page) { (status, code, results, totalpage) in
            
            if results != nil
            {
                self.onHandleSaveDataToLocal(data: results!, examinerId: self.assessorID)
                DispatchQueue.main.async {
                    self.recordList = DatabaseManagement.shared.queryAllExam(withID: self.assessorID, status: "pending")
                    self.recordsTableView.reloadData()
                }
            }
            
        }
    }

}

extension Assessor_AssessmentRecordVC: OfflineRecordDelegate
{
    func onClickStart(indexPath: IndexPath) {
        let part1 = UIStoryboard(name: "Offline", bundle: nil).instantiateViewController(withIdentifier: "part1") as! Offline_Part1
        part1.Exam = recordList[indexPath.row]
        self.navigationController?.pushViewController(part1, animated: true)

    }
}









