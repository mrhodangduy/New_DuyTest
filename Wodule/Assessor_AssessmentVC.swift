//
//  Assessor_AssessmentVC.swift
//  Wodule
//
//  Created by QTS Coder on 10/4/17.
//  Copyright © 2017 QTS. All rights reserved.
//

import UIKit

class Assessor_AssessmentVC: UIViewController {
    
    @IBOutlet weak var lbl_NoFound: UILabel!
    @IBOutlet weak var dataTableView: UITableView!
    
    let token = userDefault.object(forKey: TOKEN_STRING) as? String
    var userID:Int!
    var currentpage :Int!
    var totalPage:Int!
    
    var AllRecord = [NSDictionary]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lbl_NoFound.isHidden = true
        dataTableView.dataSource = self
        dataTableView.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getData()

    }
    
    func getData()
    {
        
        AllRecord.removeAll()
        currentpage = 1
        loadingShow()
        DispatchQueue.global(qos: .default).async { 
            
            ExamRecord.getAllRecord(page: self.currentpage, completion: { (result:[NSDictionary]?, totalPage:Int?,code:Int?, json:NSDictionary?) in
                
                if result != nil
                {
                    
                    for item in result!
                    {
                        if item["status"] as! String == "pending"
                        {
                            self.AllRecord.append(item)
                        }
                    }
                    self.totalPage = totalPage
                    DispatchQueue.main.async(execute: {
                        self.dataTableView.reloadData()
                    })
                }
                
                else if json?["code"] as! Int == 429
                {
                    
                    guard let errorMess = json?["error"] as? String else {return}
                    DispatchQueue.main.async(execute: {
                        self.loadingHide()
                        self.alertMissingText(mess: "\(errorMess)\n(ErrorCode:\(json?["code"] as! Int))", textField: nil)
                    })
                }
                else if code == 401
                {
                    if let error = json?["error"] as? String
                    {
                        if error.contains("Token")
                        {
                            self.loadingHide()
                            self.onHandleTokenInvalidAlert(autoLogin: autologin)
                        }
                    }
                }
                else
                {
                    self.lbl_NoFound.text = "No Record Found"
                    self.lbl_NoFound.isHidden = false
                    DispatchQueue.main.async(execute: {
                        self.dataTableView.reloadData()
                        self.loadingHide()
                    })

                }
                
            })
            
        }
    }
    
    @IBAction func backBtnTap(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension Assessor_AssessmentVC: UITableViewDataSource,UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AllRecord.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! Assessor_HistoryCell
        
        let item = AllRecord[indexPath.row]
        
        cell.lbl_ExamID.text = item["exam"] as? String
        cell.lbl_Score.text = "-"
        cell.lbl_Date.text = convertDay(DateString: item["creationDate"] as! String)
        cell.lbl_examinerrID.text = "\(item["examinee"] as! Int)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(at: indexPath)
        selectedCell?.contentView.backgroundColor = UIColor(red: 27/255, green: 81/255, blue: 45/255, alpha: 1)
        
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(at: indexPath)
        selectedCell?.contentView.backgroundColor = UIColor.clear
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let part1VC = UIStoryboard(name: ASSESSOR_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "gradeVC") as! Assessor_GradeVC
        
        part1VC.Exam = AllRecord[indexPath.row]
        print(AllRecord[indexPath.row])
        let identifier = self.AllRecord[indexPath.row]["identifier"] as? Int
        _ = self.AllRecord[indexPath.row]["exam"] as? String
        userDefault.set(identifier, forKey: IDENTIFIER_KEY)
        userDefault.synchronize()
        
        self.navigationController?.pushViewController(part1VC, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let lastItem = AllRecord.count-1
        if indexPath.row == lastItem && currentpage < totalPage + 1
        {
            currentpage = currentpage + 1
            loadMore(currentpage: currentpage)
            print(currentpage)
        }
        
        print("No loadmore",currentpage,totalPage)
    }
    
    func loadMore(currentpage: Int)
    {
        ExamRecord.getAllRecord(page: currentpage, completion: { (result: [NSDictionary]?, totalPage: Int?,code: Int?, json: NSDictionary?) in
            
            if var data = result
            {
                data = data.filter { $0["status"] as! String == "pending" }
                
                if data.count > 0
                {
                    for item in data
                    {
                        self.AllRecord.append(item)
                        
                    }
                    DispatchQueue.main.async(execute: {
                        self.dataTableView.reloadData()
                        self.loadingHide()
                        
                    })
                    
                }
                else
                {
                    
                    print("Current page",self.currentpage)
                    DispatchQueue.main.async(execute: {
                        self.dataTableView.reloadData()
                        self.loadingHide()
                        
                    })
                }
                
            }
            else if json?["code"] as! Int == 429
            {
                
                let errorMess = json?["error"] as? String
                DispatchQueue.main.async(execute: {
                    self.loadingHide()
                    self.alertMissingText(mess: "\(errorMess!)\n(Code:-\(json?["code"] as! Int)-)", textField: nil)
                })
            }
            else
            {
                print("ERROR:\n--->",json!)
            }
        })
        
    }
    
}
