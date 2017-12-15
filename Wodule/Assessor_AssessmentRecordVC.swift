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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recordsTableView.dataSource = self
        recordsTableView.delegate = self
        recordsTableView.register(UINib(nibName: "AssessmentRecordCell", bundle: nil)
            , forCellReuseIdentifier: "AssessmentRecordCell")

        downloadExam()
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
            ExamRecord.downloadRecord(token: self.token!, completion: { (status, code, result) in
                if status == true {
                    self.onHandleSaveDataToLocal(data: result!, examinerId: self.assessorID)
                    DispatchQueue.main.async {
                        self.recordList = DatabaseManagement.shared.queryAllExam(withID: self.assessorID, status: nil)
                        self.recordsTableView.reloadData()
                        self.loadingHide()
                    }
                }
            })
        }
        else {
            self.recordList = DatabaseManagement.shared.queryAllExam()
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

                let ids:[Int64] = DatabaseManagement.shared.queryIdentifierList(of: self.assessorID)
                if ids.contains(identifier)
                {
                    print("Already exist")
                    
                } else {
                    let insertID = DatabaseManagement.shared.addExam(identifier: identifier, examinerId: examinerId, examName: examName, status: status, examQuestionaireOne: examQuestionaireOne, examQuestionaireTwo: examQuestionaireTwo, examQuestionaireThree: examQuestionaireThree, examQuestionaireFour: examQuestionaireFour, comment_1: comment_1, comment_2: comment_2, comment_3: comment_3, comment_4: comment_4, score_1: score_1, score_2: score_2, score_3: score_3, score_4: score_4, audio_1: audio_1, audio_2: audio_2, audio_3: audio_3, audio_4: audio_4, lastChange: lastChange)
                    print(insertID as Any)
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
                    var ids = [Int]()
                    for i in 0...1
                    {
                        let id = exams[i]["identifier"] as! Int
                        ids.append(id)
                    }
                    ExamRecord.getUniqueRecord(token: self.token!, ids: ids, completion: { (status: Bool) in
                        
                        if status {
                            DispatchQueue.main.async(execute: {
                                self.downloadExam()
                            })
                        }
                    })
                    
                } else if code == 200
                {
                    DispatchQueue.main.async {
                        self.loadingHide()
                        self.alertMissingText(mess: "No exam to grade.", textField: nil)
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
        cell.id = recordList[indexPath.row].identifier
        cell.examIDLabel.text = recordList[indexPath.row].examName
       
        return cell
    }
}

extension Assessor_AssessmentRecordVC: OfflineRecordDelegate
{
    func onClickStart(id: Int64) {
        
        let delete = DatabaseManagement.shared.deleteExam(id: id)
        if delete
        {
            self.recordList = DatabaseManagement.shared.queryAllExam()
            DispatchQueue.main.async {
                self.recordsTableView.reloadData()
            }
        }
        print(delete)
        
        
    }
}









