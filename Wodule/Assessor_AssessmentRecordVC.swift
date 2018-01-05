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
    @IBOutlet weak var todayLabel: UILabelX!
    @IBOutlet weak var historyLabel: UILabelX!
    @IBOutlet weak var todayView: UIView!
    @IBOutlet weak var historyView: UIViewX!
    @IBOutlet weak var historyTableView: UITableView!
    @IBOutlet weak var noHistoryLabel: UILabel!
    @IBOutlet weak var refreshButton: UIButton!
    
    var recordList: [ExamDataStruct] = []
    let token = userDefault.object(forKey: TOKEN_STRING) as? String
    var assessorID: Int64!
    
    var historyList: [NSDictionary] = []
    var currentpageHistory:Int!
    var totalPageHistory:Int!
    var isHitoryTapped:Bool!
    
    var currentpage:Int!
    var totalPage:Int!
    
    
    fileprivate let convertdateformatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone.current
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isHitoryTapped = false
        historyView.isHidden = true
        noHistoryLabel.isHidden = true
        
        
        recordsTableView.dataSource = self
        recordsTableView.delegate = self
        historyTableView.delegate = self
        historyTableView.dataSource = self
        
        recordsTableView.register(UINib(nibName: "AssessmentRecordCell", bundle: nil), forCellReuseIdentifier: "AssessmentRecordCell")
        
        onHandleCheckExpiredExam()
        
        if ReachabilityManager.shared.reachability.isReachableViaWiFi
        {
            downloadExam()
            
        } else
        {
            self.recordList = DatabaseManagement.shared.queryAllExam(withID: self.assessorID, status: "pending")
            DispatchQueue.main.async(execute: {
                self.recordsTableView.reloadData()
                self.loadingHide()
            })
        }
    }
    
    @IBAction func onClickToday(_ sender: Any) {
        refreshButton.isHidden = false
        historyView.isHidden = true
        todayView.isHidden = false
        todayLabel.backgroundColor = .white
        todayLabel.textColor = .black
        historyLabel.textColor = .white
        historyLabel.backgroundColor = UIColor.white.withAlphaComponent(0.2)
    }
    
    @IBAction func onClickHistory(_ sender: Any) {
        
        if isHitoryTapped == false
        {
            self.onHandleInitDataOfHistory()
            isHitoryTapped = true
        }
        refreshButton.isHidden = true
        historyView.isHidden = false
        todayView.isHidden = true
        historyLabel.backgroundColor = .white
        historyLabel.textColor = .black
        todayLabel.textColor = .white
        todayLabel.backgroundColor = UIColor.white.withAlphaComponent(0.2)
    }
    
    @IBAction func onClickRefresh(_ sender: Any) {
        
        if recordList.count > 10
        {
            self.alertMissingText(mess: "You reach to limit record to download.", textField: nil)
            return
        }
        onHandleCallAPI()
            
    }

    @IBAction func onClickBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func onHandleCheckExpiredExam()
    {
        let idlistJustExpired = DatabaseManagement.shared.queryIdentifierListExpiredToUpdate(of: self.assessorID)
        print("List exam just expired", idlistJustExpired)
        if idlistJustExpired.isEmpty == false
        {
            for id in idlistJustExpired {
                let _ = DatabaseManagement.shared.updateExpiredExam(id: id)
            }
        }
        
        let idExpired = DatabaseManagement.shared.queryIdentifierListExpiredToDeleted(of: self.assessorID)
        print("List exam expired", idExpired)
        if !idExpired.isEmpty {
            for id in idExpired {
                ExamRecord.shared.examExpired(token: self.token!, id: id, completion: { (status, results) in
                    
                    if status {
                        let delete = DatabaseManagement.shared.deleteExam(id: id)
                        if delete
                        {
                            self.deleteAudioFile(fileName: "\(id)", examninerID: self.assessorID)
                        }
                        print(delete)
                    } else {
                        print("Errrorrr to delete")
                    }
                })
            }
        }
    }

    func downloadExam()
    {
        if Connectivity.isConnectedToInternet
        {
            self.loadingShow()
            currentpage = 1
            ExamRecord.shared.downloadRecord(token: self.token!, page: self.currentpage, completion: { (status, code, result, total_Page) in
                
                if status == true {
                    
                    if  !result!.isEmpty {
                        var dataAvailable = [NSDictionary]()
                        for item in result!
                        {
                            let expired_at = item["expired_at"] as! String
                            let date = self.getGMTDate(date: expired_at)
                            let time = self.gettimeRemaining(from: date)
                            print("Time remaining: ", time)
                            
                            if time < 0
                            {
                                let id = item["identifier"] as! Int64
                                ExamRecord.shared.examExpired(token: self.token!, id: id, completion: { (status, result) in
                                    print("Remove out of list", status)
                                })
                            }
                            else
                            {
                                dataAvailable.append(item)
                            }
                            
                            print("IDDDDDDDDDDD: ----->", item["identifier"] as! Int)
                        }
                        
                        self.totalPage = total_Page
                        self.onHandleSaveDataToLocal(data: dataAvailable, examinerId: self.assessorID)
                        DispatchQueue.main.async(execute: {
                            self.recordList = DatabaseManagement.shared.queryAllExam(withID: self.assessorID, status: "pending")
                            self.recordsTableView.reloadData()
                            self.loadingHide()
                        })

                    } else if result!.isEmpty
                    {
                        DispatchQueue.main.async(execute: {
                            self.loadingHide()
                            self.alertMissingText(mess: "You don't have any record.", textField: nil)
                        })
                    } else
                    {
                        DispatchQueue.main.async(execute: {
                            self.loadingHide()
                            self.alertMissingText(mess: "You reach to limit record to download.", textField: nil)
                            self.recordsTableView.reloadData()
                        })
                    }
                    
                } else if code == 429
                {
                    DispatchQueue.main.async(execute: {
                        self.recordList = DatabaseManagement.shared.queryAllExam(withID: self.assessorID, status: "pending")
                        self.loadingHide()
                        self.alertMissingText(mess: "Too Many Attempts\n(ErrorCode:\(429))", textField: nil)
                        self.recordsTableView.reloadData()
                    })
                    
                } else if code == 401
                {
                    DispatchQueue.main.async(execute: {
                        self.loadingHide()
                        self.onHandleTokenInvalidAlert()
                    })
                }
                else {
                    DispatchQueue.main.async(execute: {
                        self.recordList = DatabaseManagement.shared.queryAllExam(withID: self.assessorID, status: "pending")
                        self.loadingHide()
                        self.alertMissingText(mess: "Server error. Try again later.", textField: nil)
                        self.recordsTableView.reloadData()
                    })
                }
            })
        }
            
        else {
            self.onHandleLoadLocalData()
        }
    }
    
    func onHandleLoadLocalData()
    {
        DispatchQueue.main.async {
            self.recordList = DatabaseManagement.shared.queryAllExam(withID: self.assessorID, status: "pending")
            self.recordsTableView.reloadData()
        }
    }
    
    func onHandleDownloadImageQuestion(questions: [String?], examinerid: Int64, id: Int64)
    {
        for i in 0..<questions.count
        {
            if questions[i] == nil || questions[i]?.hasPrefix("http://wodule.io/user") == false
            {
                
                print("No photo")
                
            } else {
                
                let existPhoto = onHandleCheckFileAvailable(examiner: examinerid, id: id, savename: "question_\(i+1).jpeg")
                if existPhoto
                {
                    continue
                }
                else
                {
                    DataOffline.shared.download(url: questions[i]!, folder: "\(examinerid)", id: "\(id)", saveName: "question_\(i+1).jpeg", completionProgress: { (percent) in
                        
                        print("question_\(i+1).jpeg", percent)
                        
                    }, completion: { (status, urlString) in
                        print("!!!!!!!!!!!!!!!")
                        print("Status", status, "Urlstring:", urlString)
                    })
                }
            }
        }
    }
    
    func onHandleCheckFileAvailable(examiner: Int64, id: Int64, savename:String?) -> Bool
    {
        let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let folder = directoryURL.appendingPathComponent("\(examiner)")
        let child = folder.appendingPathComponent("\(id)")
        if savename == nil
        {
            if FileManager.default.fileExists(atPath: child.path)
            {
                print("File existsssss")
            } else
            {
                print("Not founddddddddd")
                
            }
            
            return FileManager.default.fileExists(atPath: child.path)

        } else
        {
            let photo = child.appendingPathComponent(savename!)
            if FileManager.default.fileExists(atPath: photo.path)
            {
                print("Photo existsssss")
            } else
            {
                print("Photo Not founddddddddd")
                
            }
            
            return FileManager.default.fileExists(atPath: photo.path)
        }
    }
    
    func onHandleSaveDataToLocal(data: [NSDictionary], examinerId: Int64)
    {
        if !data.isEmpty
        {
            for i in 0..<data.count {
                if self.recordList.count == 10 {
                    return
                }
                let examItem = data[i]
                let identifier = examItem["identifier"] as! Int64
                let status = examItem["status"] as! String
                if status == "graded"
                {
                    print("\(identifier) --> graded")
                    continue
                }
                
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
                let expired_at = examItem["expired_at"] as! String
                var isExpired: Bool!
                
                let date = getGMTDate(date: expired_at)
                let time = gettimeRemaining(from: date)
                isExpired = time < 0 ? true : false
                let idExpired = DatabaseManagement.shared.queryIdentifierListExpiredToDeleted(of: examinerId)
                let ids:[Int64] = DatabaseManagement.shared.queryIdentifierList(of: examinerId)
                
                if ids.contains(identifier)
                {
                    print("\(identifier) --> Already exist")
                    let idsList = DatabaseManagement.shared.queryIdentifiersNotDownloadAudio(of: examinerId)
                    print(idsList)
                    let existFile = self.onHandleCheckFileAvailable(examiner: examinerId, id: identifier, savename: nil)
                    
                    if !existFile && !idExpired.contains(identifier)
                    {
                        
                        let questionArray: [String?] = [examQuestionaireOne, examQuestionaireTwo, examQuestionaireThree, examQuestionaireFour]
                        self.onHandleDownloadImageQuestion(questions: questionArray, examinerid: examinerId, id: identifier)
                        
                        let update = DatabaseManagement.shared.updateExamDownload(id: identifier, isDownloaded: false)
                        print(update)
                        if update
                        {
                            self.recordList = DatabaseManagement.shared.queryAllExam(withID: examinerId, status: "pending")
                            DispatchQueue.main.async(execute: {
                                self.recordsTableView.reloadData()
                            })
                        }
                        
                        if audio_3 != nil {
                            
                            var percent1: Double = 0
                            var percent2: Double = 0
                            var percent3: Double = 0
                            var percent4: Double = 0
                            
                            DataOffline.shared.download(url: audio_1!, folder: "\(examinerId)", id: "\(identifier)", saveName: "audio_1.mp3", completionProgress: { (percent) in
                                
                                percent1 = percent
                                self.onHandleProgressDownloadTotal(id: identifier, percent1: percent1, percent2: percent2, percent3: percent3, percent4: percent4)
                                
                            }, completion: { (status, urlString) in
                                
                            })
                            
                            DataOffline.shared.download(url: audio_2!, folder: "\(examinerId)", id: "\(identifier)", saveName: "audio_2.mp3", completionProgress: { (percent) in

                                percent2 = percent
                                self.onHandleProgressDownloadTotal(id: identifier, percent1: percent1, percent2: percent2, percent3: percent3, percent4: percent4)
                                
                            }, completion: { (status, urlString) in
                                
                            })
                            DataOffline.shared.download(url: audio_3!, folder: "\(examinerId)", id: "\(identifier)", saveName: "audio_3.mp3", completionProgress: { (percent) in

                                percent3 = percent
                                self.onHandleProgressDownloadTotal(id: identifier, percent1: percent1, percent2: percent2, percent3: percent3, percent4: percent4)
                                
                                
                            }, completion: { (status, urlString) in
                                
                            })
                            DataOffline.shared.download(url: audio_4!, folder: "\(examinerId)", id: "\(identifier)", saveName: "audio_4.mp3", completionProgress: { (percent) in
                                percent4 = percent
                                self.onHandleProgressDownloadTotal(id: identifier, percent1: percent1, percent2: percent2, percent3: percent3, percent4: percent4)
                                
                            }, completion: { (status, urlString) in
                                
                            })
                            
                        } else {
                            
                            var percent1: Double = 0
                            var percent2: Double = 0
                            
                            DataOffline.shared.download(url: audio_1!, folder: "\(examinerId)", id: "\(identifier)", saveName: "audio_1.mp3", completionProgress: { (percent) in
                                
                                percent1 = percent
                                self.onHandleProgressDownloadTotal(id: identifier, percent1: percent1, percent2: percent2, percent3: nil, percent4: nil)
                                
                                
                            }, completion: { (status, urlString) in
                                
                            })
                            
                            DataOffline.shared.download(url: audio_2!, folder: "\(examinerId)", id: "\(identifier)", saveName: "audio_2.mp3", completionProgress: { (percent) in
                                
                                percent2 = percent
                                self.onHandleProgressDownloadTotal(id: identifier, percent1: percent1, percent2: percent2, percent3: nil, percent4: nil)
                                
                                
                            }, completion: { (status, urlString) in
                                
                            })
                        }
                    }
                    
                    else if idsList.contains(identifier)
                    {
//                        let update = DatabaseManagement.shared.updateExamDownload(id: identifier, isDownloaded: true)
//                        print(update)
//                        if update
//                        {
                            self.recordList = DatabaseManagement.shared.queryAllExam(withID: examinerId, status: "pending")
                            DispatchQueue.main.async(execute: {
                                self.recordsTableView.reloadData()
                            })
//                        }
                    } else
                    {
                        print("Downloaded")
                    }
                    
                } else {
                    let questionArray: [String?] = [examQuestionaireOne, examQuestionaireTwo, examQuestionaireThree, examQuestionaireFour]
                    self.onHandleDownloadImageQuestion(questions: questionArray, examinerid: examinerId, id: identifier)

                    let insertID = DatabaseManagement.shared.addExam(identifier: identifier, examinerId: examinerId, examName: examName, status: status, examQuestionaireOne: examQuestionaireOne, examQuestionaireTwo: examQuestionaireTwo, examQuestionaireThree: examQuestionaireThree, examQuestionaireFour: examQuestionaireFour, comment_1: comment_1, comment_2: comment_2, comment_3: comment_3, comment_4: comment_4, score_1: score_1, score_2: score_2, score_3: score_3, score_4: score_4, audio_1: audio_1, audio_2: audio_2, audio_3: audio_3, audio_4: audio_4, expired_at: expired_at, isExpired: isExpired, isDownload: false, progressDownload: 0)
                    print(insertID as Any)
                    print(isExpired)
                    if insertID != nil
                    {
                        if audio_3 != nil {
                            
                            var percent1: Double = 0
                            var percent2: Double = 0
                            var percent3: Double = 0
                            var percent4: Double = 0

                            DataOffline.shared.download(url: audio_1!, folder: "\(examinerId)", id: "\(identifier)", saveName: "audio_1.mp3", completionProgress: { (percent) in
                                percent1 = percent
                                self.onHandleProgressDownloadTotal(id: identifier, percent1: percent1, percent2: percent2, percent3: percent3, percent4: percent4)
                                
                                
                            }, completion: { (status, urlString) in
                                
                            })
                            
                            DataOffline.shared.download(url: audio_2!, folder: "\(examinerId)", id: "\(identifier)", saveName: "audio_2.mp3", completionProgress: { (percent) in
                                percent2 = percent
                                self.onHandleProgressDownloadTotal(id: identifier, percent1: percent1, percent2: percent2, percent3: percent3, percent4: percent4)
                                
                                
                            }, completion: { (status, urlString) in
                                
                            })
                            DataOffline.shared.download(url: audio_3!, folder: "\(examinerId)", id: "\(identifier)", saveName: "audio_3.mp3", completionProgress: { (percent) in
                                percent3 = percent
                                self.onHandleProgressDownloadTotal(id: identifier, percent1: percent1, percent2: percent2, percent3: percent3, percent4: percent4)
                                
                                
                            }, completion: { (status, urlString) in
                                
                            })
                            DataOffline.shared.download(url: audio_4!, folder: "\(examinerId)", id: "\(identifier)", saveName: "audio_4.mp3", completionProgress: { (percent) in
                                percent4 = percent
                                self.onHandleProgressDownloadTotal(id: identifier, percent1: percent1, percent2: percent2, percent3: percent3, percent4: percent4)
                                
                                
                                
                            }, completion: { (status, urlString) in
                                
                            })
                            
                            
                        } else {
                            
                            var percent1: Double = 0
                            var percent2: Double = 0
                            
                            DataOffline.shared.download(url: audio_1!, folder: "\(examinerId)", id: "\(identifier)", saveName: "audio_1.mp3", completionProgress: { (percent) in
                                percent1 = percent
                                self.onHandleProgressDownloadTotal(id: identifier, percent1: percent1, percent2: percent2, percent3: nil, percent4: nil)
                                
                            }, completion: { (status, urlString) in
                                
                            })
                            
                            DataOffline.shared.download(url: audio_2!, folder: "\(examinerId)", id: "\(identifier)", saveName: "audio_2.mp3", completionProgress: { (percent) in
                                percent2 = percent
                                self.onHandleProgressDownloadTotal(id: identifier, percent1: percent1, percent2: percent2, percent3: nil, percent4: nil)
                                
                                
                            }, completion: { (status, urlString) in
                                
                            })
                        }
                    }
                }
            }
        }
        
    }
    
    func onHandleProgressDownloadTotal(id: Int64, percent1: Double, percent2: Double, percent3: Double?, percent4: Double?)
    {
        if percent3 == nil
        {
            let totalPercent: Int64 = Int64((percent1 + percent2)) / 2
            print("Progress:", totalPercent, "%")
            
            if totalPercent % 5 == 0
            {
                if totalPercent != 100
                {
                    let update = DatabaseManagement.shared.updateProgressDownload(id: id, percent: totalPercent)
                    if update {
                        self.recordList = DatabaseManagement.shared.queryAllExam(withID: self.assessorID, status: "pending")
                        DispatchQueue.main.async(execute: {
                            self.recordsTableView.reloadData()
                        })
                    }
                } else {
                    let _ = DatabaseManagement.shared.updateProgressDownload(id: id, percent: totalPercent)
                }
                
            }
            
            if totalPercent == 100 {
                
                let update = DatabaseManagement.shared.updateExamDownload(id: id, isDownloaded: true)
                print(update)
                if update
                {
                    self.recordList = DatabaseManagement.shared.queryAllExam(withID: self.assessorID, status: "pending")
                    DispatchQueue.main.async(execute: {
                        self.recordsTableView.reloadData()
                    })
                }
                
            }

        } else {
            
            let totalPercent: Int64 = Int64((percent1 + percent2 + percent3! + percent4!)) / 4
            print("Progress:", totalPercent, "%")
            
            if totalPercent % 5 == 0
            {
                let update = DatabaseManagement.shared.updateProgressDownload(id: id, percent: totalPercent)
                if update {
                    self.recordList = DatabaseManagement.shared.queryAllExam(withID: self.assessorID, status: "pending")
                    DispatchQueue.main.async(execute: {
                        self.recordsTableView.reloadData()
                    })
                }
            }
            
            if totalPercent == 100 {
                
                let update = DatabaseManagement.shared.updateExamDownload(id: id, isDownloaded: true)
                print(update)
                if update
                {
                    self.recordList = DatabaseManagement.shared.queryAllExam(withID: self.assessorID, status: "pending")
                    DispatchQueue.main.async(execute: {
                        self.recordsTableView.reloadData()
                    })
                }
                
            }

        }
    }
    
    func onHandleCallAPI()
    {
        if Connectivity.isConnectedToInternet
        {
            self.loadingShow()
            ParallelServiceCaller.shared.startServiceCall(completionHandle: { (status, code, dataRecords, error) in
                
                if status
                {
                    if !dataRecords!.isEmpty {
                        DispatchQueue.main.async(execute: {
                            print("download")
                            self.downloadExam()
                        })
                    } else {
                        DispatchQueue.main.async {
                            self.loadingHide()
                            self.alertMissingText(mess: "No exam to download.", textField: nil)
                            self.recordsTableView.reloadData()
                        }
                    }
                } else if code == 429
                {
                    if let errorMess = (error?["error"] as? String)
                    {
                        DispatchQueue.main.async(execute: {
                            self.loadingHide()
                            self.alertMissingText(mess: "\(errorMess)\n(ErrorCode:\(error?["code"] as! Int))", textField: nil)
                            self.recordsTableView.reloadData()
                        })
                    } else {
                        DispatchQueue.main.async(execute: {
                            self.loadingHide()
                            self.alertMissingText(mess: "Server error. Try again later.", textField: nil)
                            self.recordsTableView.reloadData()
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
    
    func onHandleInitDataOfHistory()
    {
        currentpageHistory = 1
        self.loadingShow()
        AssesmentHistory.shared.getUserHistory(type: "grades", withToken: self.token!, userID: Int(self.assessorID), page: self.currentpageHistory) { (status,code,mess, results, totalpage) in
            
            if status!
            {
                if results?.count != 0
                {
                    self.historyList.removeAll()
                    self.totalPageHistory = totalpage
                    for result in results!
                    {
                        self.historyList.append(result)
                        DispatchQueue.main.async(execute: {
                            self.historyTableView.reloadData()
                            self.loadingHide()
                        })
                    }
                }
                else
                {
                    DispatchQueue.main.async(execute: {
                        self.historyTableView.reloadData()
                        self.loadingHide()
                        self.noHistoryLabel.isHidden = false
                    })
                }
            }
            else if code == 401
            {
                if let error = mess?["error"] as? String
                {
                    if error.contains("Token")
                    {
                        DispatchQueue.main.async(execute: { 
                            self.loadingHide()
                            self.onHandleTokenInvalidAlert()
                        })
                        
                    }
                }
            }
            else
            {
                print("\nERROR:---->",mess as Any)
                DispatchQueue.main.async(execute: {
                    self.historyTableView.reloadData()
                    self.loadingHide()
                    
                })
                
            }
            
        }
    }
    
}

extension Assessor_AssessmentRecordVC: UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.recordsTableView
        {
            return recordList.count

        } else {
            return historyList.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == self.recordsTableView
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AssessmentRecordCell", for: indexPath) as! AssessmentRecordCell
            cell.selectionStyle = .none
            cell.delegate = self
            cell.indexPath = indexPath
            cell.examIDLabel.text = recordList[indexPath.row].examName
            cell.downloadingLabel.text = "\(recordList[indexPath.row].progressDownload)" + "%"
           
            if recordList[indexPath.row].isDownloaded == true
            {
                cell.startButton.isHidden = false
                
            } else
            {
                cell.startButton.isHidden = true
                
            }
            
            return cell
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! Examinee_HistoryCell
            
            let item = historyList[indexPath.row]
            
            cell.lbl_date.text = convertDayHistory(DateString: item["creationDate"] as! String)
            cell.lbl_ExamID.text = item["exam"] as? String
            
            if item["score"] as? String == "pending"
            {
                cell.lbl_Point.text = "-"
            }
            else
            {
                cell.lbl_Point.text = item["score"] as? String
            }
            
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if Connectivity.isConnectedToInternet
        {
            if tableView == self.recordsTableView
            {
                

            } else {
                let lastItem = historyList.count - 2
                if indexPath.row == lastItem && currentpageHistory < totalPageHistory
                {
                    currentpageHistory = currentpageHistory + 1
                    loadmoreHitory(page: currentpageHistory)
                    print(currentpageHistory)
                }
                
                print("No loadmore",currentpageHistory,totalPageHistory)
            }
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.recordsTableView
        {
            print(recordList[indexPath.row].description)

        } else {
            
            tableView.deselectRow(at: indexPath, animated: true)
            let examdetailVC = UIStoryboard(name: EXAMINEE_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "examdetailVC") as! Examinee_ExamDetailVC
            
            examdetailVC.ExamDetail = historyList[indexPath.row]
            
            self.navigationController?.pushViewController(examdetailVC, animated: true)
            
            print("HISTORY\n----->",historyList[indexPath.row])
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    
    
    func loadmoreHitory(page:Int)
    {
        AssesmentHistory.shared.getUserHistory(type: "grades", withToken: token!, userID: Int(self.assessorID), page: page) { (status,code, data, results, totolPage) in
            
            if results != nil
            {
                for item in results!
                {
                    self.historyList.append(item)
                    DispatchQueue.main.async(execute: {
                        self.historyTableView.reloadData()
                    })
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









