//
//  AssessmentHistoryVC.swift
//  Wodule
//
//  Created by QTS Coder on 10/3/17.
//  Copyright © 2017 QTS. All rights reserved.
//

import UIKit


class AssessmentHistoryVC: UIViewController {
    
    @IBOutlet weak var lbl_NoFound: UILabel!
    var History = [NSDictionary]()
    let token = userDefault.object(forKey: TOKEN_STRING) as? String
    var userID:Int!
    var currentpage:Int!
    var totalPage:Int!
    
    
    @IBOutlet weak var dataTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        super.viewDidLoad()
        
        lbl_NoFound.isHidden = true
        lbl_NoFound.text = "No Assessment Found"
        
        dataTableView.dataSource = self
        dataTableView.delegate = self
        
        currentpage = 1
        
        loadingShow()
        AssesmentHistory.getUserHistory(withToken: token!, userID: userID, page: currentpage) { (status,code,mess, results, totalpage) in
            
            if status!
            {
                if results?.count != 0
                {
                    print("\n\nHISTORY LIST:--->\n",results)
                    self.totalPage = totalpage
                    for result in results!
                    {
                        self.History.append(result)
                        DispatchQueue.main.async(execute: {
                            self.loadingHide()
                            self.dataTableView.reloadData()
                            
                        })
                        
                    }
                }
                else
                {
                    DispatchQueue.main.async(execute: {
                        self.loadingHide()
                        self.dataTableView.reloadData()
                        self.lbl_NoFound.isHidden = false
                    })
                }
                
                
            }
            else if code == 401
            {
                if let error = mess?["error"] as? String
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
                print("\nERROR:---->",mess!)
                DispatchQueue.main.async(execute: {
                    self.loadingHide()
                    self.dataTableView.reloadData()
                    
                })
                
            }
            
        }
        
        
    }
    
    
    @IBAction func backBtnTap(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension AssessmentHistoryVC: UITableViewDataSource,UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return History.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! Examinee_HistoryCell
        
        let historyItem = History[indexPath.row]
        
        cell.lbl_date.text = convertDay(DateString: historyItem["creationDate"] as! String)
        cell.lbl_ExamID.text = historyItem["exam"] as? String
        
        if historyItem["score"] as? String == "pending"
        {
            cell.lbl_Point.text = "-"
        }
        else
        {
            cell.lbl_Point.text = historyItem["score"] as? String
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        let examdetailVC = UIStoryboard(name: EXAMINEE_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "examdetailVC") as! Examinee_ExamDetailVC
        
        examdetailVC.ExamDetail = History[indexPath.row]
        
        self.navigationController?.pushViewController(examdetailVC, animated: true)
        
        print("HISTORY\n----->",History[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(at: indexPath)
        selectedCell?.contentView.backgroundColor = UIColor(red: 27/255, green: 81/255, blue: 45/255, alpha: 1)

    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(at: indexPath)
        selectedCell?.contentView.backgroundColor = UIColor.clear
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let lastItem = History.count - 2
        if indexPath.row == lastItem && currentpage < totalPage + 1
        {
            currentpage = currentpage + 1
            loadmore(page: currentpage)
            print(currentpage)
        }
        
        print("No loadmore",currentpage,totalPage)
    }
    
    func loadmore(page:Int)
    {
        AssesmentHistory.getUserHistory(withToken: token!, userID: userID, page: page) { (status,code, data, results, totolPage) in
            
            if results != nil
            {
                for item in results!
                {
                    self.History.append(item)
                    DispatchQueue.main.async(execute: {
                        self.dataTableView.reloadData()
                    })
                }
            }
            
        }
    }
    
}
