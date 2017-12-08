//
//  Assessor_AssessmentRecordVC.swift
//  Wodule
//
//  Created by QTS Coder on 12/8/17.
//  Copyright © 2017 QTS. All rights reserved.
//

import UIKit

class Assessor_AssessmentRecordVC: UIViewController {
    @IBOutlet weak var recordsTableView: UITableView!
    
    var recordList: [NSDictionary] = []
    let token = userDefault.object(forKey: TOKEN_STRING) as? String

    override func viewDidLoad() {
        super.viewDidLoad()
        recordsTableView.dataSource = self
        recordsTableView.delegate = self
        recordsTableView.register(UINib(nibName: "AssessmentRecordCell", bundle: nil)
            , forCellReuseIdentifier: "AssessmentRecordCell")

        
        ExamRecord.downloadRecord(token: self.token!, completion: { (status, code, result) in
            if status == true {
                self.recordList = result!
                DispatchQueue.main.async {
                    self.recordsTableView.reloadData()
                    self.loadingHide()
                }
            }
        })

        
//        onHandleCallAPI()
    }
    @IBAction func onClickRefresh(_ sender: Any) {
        onHandleCallAPI()
    }

    @IBAction func onClickBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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
                    for i in 0...1
                    {
                        let id = exams[i]["identifier"] as! Int
                        ExamRecord.getUniqueRecord(token: self.token!, id: id, completion: { (status: Bool, code: Int, results: NSDictionary?) in
                            print("status",status)
                        })
                    }
                    ExamRecord.downloadRecord(token: self.token!, completion: { (status, code, result) in
                        if status == true {
                            self.recordList = result!
                            DispatchQueue.main.async {
                                self.recordsTableView.reloadData()
                                self.loadingHide()
                            }
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
        cell.examIDLabel.text = recordList[indexPath.row]["exam"] as? String
       
        return cell
    }
}
