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
    
    var recordList: [ExamDataStruct] = []
    let token = userDefault.object(forKey: TOKEN_STRING) as? String
    var assessorID: Int64!
    
    var historyList: [NSDictionary] = []
    var currentpageHistory:Int!
    var totalPageHistory:Int!
    var isHitoryTapped:Bool!
    
    var currentpage:Int!
    var totalPage:Int!
    
    var refresh = false
    
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
        
        downloadExam()
    }
    
    @IBAction func onClickToday(_ sender: Any) {
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
        historyView.isHidden = false
        todayView.isHidden = true
        historyLabel.backgroundColor = .white
        historyLabel.textColor = .black
        todayLabel.textColor = .white
        todayLabel.backgroundColor = UIColor.white.withAlphaComponent(0.2)
    }
    
    @IBAction func onClickRefresh(_ sender: Any) {
        
        if !refresh
        {
            onHandleCallAPI()
        } else
        {
            downloadExam()
        }
        
        refresh = !refresh
        
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
                    for item in result!
                    {
                        print("IDDDDDDDDDDD: ----->", item["identifier"] as! Int)
                    }
                    self.totalPage = total_Page
                    self.onHandleSaveDataToLocal(data: result!, examinerId: self.assessorID)
                    self.recordList = DatabaseManagement.shared.queryAllExam(withID: self.assessorID, status: "pending")
                    DispatchQueue.main.async(execute: {
                        self.recordsTableView.reloadData()
                        self.loadingHide()
                    })
                } else if code == 429
                {
                    DispatchQueue.main.async(execute: {
                        self.loadingHide()
                        self.alertMissingText(mess: "Too Many Attempts\n(ErrorCode:\(429))", textField: nil)
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
                        self.loadingHide()
                        self.alertMissingText(mess: "Server error. Try again later.", textField: nil)
                    })
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
    
    func onHandleDownloadImageQuestion(questions: [String?], examinerid: Int64, id: Int64)
    {
        for i in 0..<questions.count
        {
            if questions[i] == nil || questions[i]?.hasPrefix("http://wodule.io/user") == false
            {
                
                print("No photo")
                
            } else {
                
                DataOffline.shared.download(url: questions[i]!, folder: "\(examinerid)", id: "\(id)", saveName: "question_\(i+1).jpeg", completionProgress: { (percent) in
                    
                    print("question_\(i+1).jpeg", percent)
                    
                }, completion: { (status, urlString) in
                    print("!!!!!!!!!!!!!!!")
                    print("Status", status, "Urlstring:", urlString)
                })
            }
        }
    }
    
    func onHandleCheckFileAvailable(examiner: Int64, id: Int64) -> Bool
    {
        let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let folder = directoryURL.appendingPathComponent("\(examiner)")
        let child = folder.appendingPathComponent("\(id)")
        
        if FileManager.default.fileExists(atPath: child.path)
        {
            print("FIle existsssss")
        } else
        {
            print("Not founddddddddd")

        }
        
        return FileManager.default.fileExists(atPath: child.path)

    }
    
    func onHandleSaveDataToLocal(data: [NSDictionary], examinerId: Int64)
    {
        if !data.isEmpty
        {
            for i in 0..<data.count {
                let examItem = data[i]
                let status = examItem["status"] as! String
                if status == "graded"
                {
                    continue
                }
                
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
                let expired_at = examItem["expired_at"] as! String
                var isExpired: Bool!
                
                let date = getGMTDate(date: expired_at)
                let time = gettimeRemaining(from: date)
                print("TIme remaining: ", time)
                isExpired = time < 0 ? true : false                
                
                let ids:[Int64] = DatabaseManagement.shared.queryIdentifierList(of: examinerId)
                if ids.contains(identifier)
                {
                    print("Already exist")
                    let idsList = DatabaseManagement.shared.queryIdentifiersNotDownloadAudio(of: examinerId)
                    print(idsList)
                    let existFile = self.onHandleCheckFileAvailable(examiner: examinerId, id: identifier)
                    
                    if !existFile
                    {
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
                            var part1Completion = false
                            var part2Completion = false
                            var part3Completion = false
                            var part4Completion = false
                            
                            DataOffline.shared.download(url: audio_1!, folder: "\(examinerId)", id: "\(identifier)", saveName: "audio_1.mp3", completionProgress: { (percent) in
                                print("audio1", percent)
                                if percent == 100
                                {
                                    part1Completion = true
                                    self.onHandleUpdateAndReloadData(part1: part1Completion, part2: part2Completion, part3: part3Completion, part4: part4Completion, id: identifier)
                                }
                                
                            }, completion: { (status, urlString) in
                                
                            })
                            
                            DataOffline.shared.download(url: audio_2!, folder: "\(examinerId)", id: "\(identifier)", saveName: "audio_2.mp3", completionProgress: { (percent) in
                                print("audio2", percent)
                                
                                if percent == 100
                                {
                                    part2Completion = true
                                    self.onHandleUpdateAndReloadData(part1: part1Completion, part2: part2Completion, part3: part3Completion, part4: part4Completion, id: identifier)
                                }
                                
                            }, completion: { (status, urlString) in
                                
                            })
                            DataOffline.shared.download(url: audio_3!, folder: "\(examinerId)", id: "\(identifier)", saveName: "audio_3.mp3", completionProgress: { (percent) in
                                print("audio3", percent)
                                
                                if percent == 100
                                {
                                    part3Completion = true
                                    self.onHandleUpdateAndReloadData(part1: part1Completion, part2: part2Completion, part3: part3Completion, part4: part4Completion, id: identifier)
                                }
                                
                            }, completion: { (status, urlString) in
                                
                            })
                            DataOffline.shared.download(url: audio_4!, folder: "\(examinerId)", id: "\(identifier)", saveName: "audio_4.mp3", completionProgress: { (percent) in
                                print("audio4", percent)
                                
                                if percent == 100
                                {
                                    part4Completion = true
                                    self.onHandleUpdateAndReloadData(part1: part1Completion, part2: part2Completion, part3: part3Completion, part4: part4Completion, id: identifier)
                                }
                                
                            }, completion: { (status, urlString) in
                                
                            })
                            
                            
                        } else {
                            
                            var part1Completion = false
                            var part2Completion = false
                            
                            DataOffline.shared.download(url: audio_1!, folder: "\(examinerId)", id: "\(identifier)", saveName: "audio_1.mp3", completionProgress: { (percent) in
                                print("audio1", percent)
                                
                                if percent == 100
                                {
                                    part1Completion = true
                                    self.onHandleUpdateAndReloadData(part1: part1Completion, part2: part2Completion, part3: nil, part4: nil, id: identifier)
                                }
                                
                            }, completion: { (status, urlString) in
                                
                            })
                            
                            DataOffline.shared.download(url: audio_2!, folder: "\(examinerId)", id: "\(identifier)", saveName: "audio_2.mp3", completionProgress: { (percent) in
                                print("audio2", percent)
                                
                                if percent == 100
                                {
                                    part2Completion = true
                                    self.onHandleUpdateAndReloadData(part1: part1Completion, part2: part2Completion, part3: nil, part4: nil, id: identifier)
                                }
                                
                            }, completion: { (status, urlString) in
                                
                            })
                        }
                    }
                    
                    else if idsList.contains(identifier)
                    {
                        let update = DatabaseManagement.shared.updateExamDownload(id: identifier, isDownloaded: true)
                        print(update)
                        if update
                        {
                            self.recordList = DatabaseManagement.shared.queryAllExam(withID: examinerId, status: "pending")
                            DispatchQueue.main.async(execute: {
                                self.recordsTableView.reloadData()
                            })
                        }
                    } else
                    {
                        print("Downloaded")
                    }
                    
                } else {
                    let questionArray: [String?] = [examQuestionaireOne, examQuestionaireTwo, examQuestionaireThree, examQuestionaireFour]
                    self.onHandleDownloadImageQuestion(questions: questionArray, examinerid: examinerId, id: identifier)

                    let insertID = DatabaseManagement.shared.addExam(identifier: identifier, examinerId: examinerId, examName: examName, status: status, examQuestionaireOne: examQuestionaireOne, examQuestionaireTwo: examQuestionaireTwo, examQuestionaireThree: examQuestionaireThree, examQuestionaireFour: examQuestionaireFour, comment_1: comment_1, comment_2: comment_2, comment_3: comment_3, comment_4: comment_4, score_1: score_1, score_2: score_2, score_3: score_3, score_4: score_4, audio_1: audio_1, audio_2: audio_2, audio_3: audio_3, audio_4: audio_4, expired_at: expired_at, isExpired: isExpired, isDownload: false)
                    print(insertID as Any)
                    if insertID != nil
                    {
                        if audio_3 != nil {
                            var part1Completion = false
                            var part2Completion = false
                            var part3Completion = false
                            var part4Completion = false

                            DataOffline.shared.download(url: audio_1!, folder: "\(examinerId)", id: "\(identifier)", saveName: "audio_1.mp3", completionProgress: { (percent) in
                                print("audio1", percent)
                                if percent == 100
                                {
                                    part1Completion = true
                                    self.onHandleUpdateAndReloadData(part1: part1Completion, part2: part2Completion, part3: part3Completion, part4: part4Completion, id: identifier)
                                }
                                
                            }, completion: { (status, urlString) in
                                
                            })
                            
                            DataOffline.shared.download(url: audio_2!, folder: "\(examinerId)", id: "\(identifier)", saveName: "audio_2.mp3", completionProgress: { (percent) in
                                print("audio2", percent)

                                if percent == 100
                                {
                                    part2Completion = true
                                    self.onHandleUpdateAndReloadData(part1: part1Completion, part2: part2Completion, part3: part3Completion, part4: part4Completion, id: identifier)
                                }
                                
                            }, completion: { (status, urlString) in
                                
                            })
                            DataOffline.shared.download(url: audio_3!, folder: "\(examinerId)", id: "\(identifier)", saveName: "audio_3.mp3", completionProgress: { (percent) in
                                print("audio3", percent)

                                if percent == 100
                                {
                                    part3Completion = true
                                    self.onHandleUpdateAndReloadData(part1: part1Completion, part2: part2Completion, part3: part3Completion, part4: part4Completion, id: identifier)
                                }
                                
                            }, completion: { (status, urlString) in
                                
                            })
                            DataOffline.shared.download(url: audio_4!, folder: "\(examinerId)", id: "\(identifier)", saveName: "audio_4.mp3", completionProgress: { (percent) in
                                print("audio4", percent)

                                if percent == 100
                                {
                                    part4Completion = true
                                    self.onHandleUpdateAndReloadData(part1: part1Completion, part2: part2Completion, part3: part3Completion, part4: part4Completion, id: identifier)
                                }
                                
                            }, completion: { (status, urlString) in
                                
                            })
                            
                            
                        } else {
                            
                            var part1Completion = false
                            var part2Completion = false
                            
                            DataOffline.shared.download(url: audio_1!, folder: "\(examinerId)", id: "\(identifier)", saveName: "audio_1.mp3", completionProgress: { (percent) in
                                print("audio1", percent)

                                if percent == 100
                                {
                                    part1Completion = true
                                    self.onHandleUpdateAndReloadData(part1: part1Completion, part2: part2Completion, part3: nil, part4: nil, id: identifier)
                                }
                                
                            }, completion: { (status, urlString) in
                                
                            })
                            
                            DataOffline.shared.download(url: audio_2!, folder: "\(examinerId)", id: "\(identifier)", saveName: "audio_2.mp3", completionProgress: { (percent) in
                                print("audio2", percent)

                                if percent == 100
                                {
                                    part2Completion = true
                                    self.onHandleUpdateAndReloadData(part1: part1Completion, part2: part2Completion, part3: nil, part4: nil, id: identifier)
                                }
                                
                            }, completion: { (status, urlString) in
                                
                            })
                        }

                    }
                }
            }
        }
        
    }
    
    func onHandleUpdateAndReloadData(part1: Bool, part2: Bool, part3: Bool?, part4 : Bool?, id: Int64)
    {
        if part3 != nil
        {
            if part1 && part2 && part3! && part4!
            {
                let update = DatabaseManagement.shared.updateExamDownload(id: id, isDownloaded: true)
                print(update)
                if update
                {
                    self.recordList = DatabaseManagement.shared.queryAllExam(withID: self.assessorID, status: "pending")
                    DispatchQueue.main.async(execute: {
                        self.recordsTableView.reloadData()
                    })
                }
            } else {
                print("Still downloading more audio")
            }
        } else
        {
            if part1 && part2
            {
                let update = DatabaseManagement.shared.updateExamDownload(id: id, isDownloaded: true)
                print(update)
                if update
                {
                    self.recordList = DatabaseManagement.shared.queryAllExam(withID: self.assessorID, status: "pending")
                    DispatchQueue.main.async(execute: {
                        self.recordsTableView.reloadData()
                    })
                }
            } else {
                print("Still downloading more audio")
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
                        
                        self.downloadExam()
                        
                    } else {
                        DispatchQueue.main.async {
                            self.loadingHide()
                            self.alertMissingText(mess: "No exam to download.", textField: nil)
                        }
                    }
                } else if code == 429
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
    
    func onHandleInitDataOfHistory()
    {
        currentpageHistory = 1
        self.loadingShow()
        AssesmentHistory.getUserHistory(type: "grades", withToken: self.token!, userID: Int(self.assessorID), page: self.currentpageHistory) { (status,code,mess, results, totalpage) in
            
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
            if recordList[indexPath.row].isDownloaded == true
            {
                cell.startButton.isHidden = false
                cell.downloadingLabel.isHidden = true
            } else
            {
                cell.startButton.isHidden = true
                cell.downloadingLabel.isHidden = false
                
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
                let lastItem = recordList.count - 2
                if indexPath.row == lastItem && currentpage < totalPage + 1
                {
                    currentpage = currentpage + 1
                    loadmore(page: currentpage)
                    print(currentpage)
                }
                
                print("No loadmore",currentpage,totalPage)

            } else {
                let lastItem = historyList.count - 2
                if indexPath.row == lastItem && currentpageHistory < totalPageHistory + 1
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
    
    func loadmore(page:Int)
    {
        ExamRecord.downloadRecord(token: self.token!, page: page) { (status, code, results, totalpage) in
            
            if results != nil
            {
                self.onHandleSaveDataToLocal(data: results!, examinerId: self.assessorID)
                self.recordList = DatabaseManagement.shared.queryAllExam(withID: self.assessorID, status: "pending")
                DispatchQueue.main.async {
                    self.recordsTableView.reloadData()
                }
            }
            
        }
    }
    func loadmoreHitory(page:Int)
    {
        AssesmentHistory.getUserHistory(type: "grades", withToken: token!, userID: Int(self.assessorID), page: page) { (status,code, data, results, totolPage) in
            
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









