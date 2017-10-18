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
        
        loadNewData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.loadNewData), name: NSNotification.Name(rawValue: "post grade"), object: nil)
        
    }
    
    func loadNewData()
    {
        currentpage = 1
        loadingShow()
        DispatchQueue.global(qos: .default).async {
            
            ExamRecord.getAllRecord(page: self.currentpage, completion: { (result: [NSDictionary]?, totalPage: Int?, json:NSDictionary?) in
                
                if result != nil
                {
                    self.AllRecord = result!
                    self.totalPage = totalPage
                    DispatchQueue.main.async(execute: {
                        self.AllRecord = self.AllRecord.filter { $0["score"] as! Int == 0 }
                        self.dataTableView.reloadData()
                        self.loadingHide()
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let part1VC = UIStoryboard(name: ASSESSOR_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "gradeVC") as! Assessor_GradeVC
        part1VC.Exam = AllRecord[indexPath.row]
        
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
        ExamRecord.getAllRecord(page: currentpage, completion: { (result: [NSDictionary]?, totalPage: Int?, json: NSDictionary?) in
            
            if result != nil
            {
                for item in result!
                {
                    if (item["score"] as! Int) == 0
                    {
                        self.AllRecord.append(item)
                        DispatchQueue.main.async(execute: {
                            self.dataTableView.reloadData()
                        })
                    }
                    
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
