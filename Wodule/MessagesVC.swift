//
//  MessagesVC.swift
//  Wodule
//
//  Created by QTS Coder on 11/6/17.
//  Copyright © 2017 QTS. All rights reserved.
//

import UIKit

class MessagesVC: UIViewController {

    @IBOutlet weak var messageTableView: UITableView!
    
    let token = userDefault.object(forKey: TOKEN_STRING) as? String
    
    var messagesList = [NSDictionary]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageTableView.delegate = self
        messageTableView.dataSource = self
        messageTableView.layer.cornerRadius = 10
               
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if Connectivity.isConnectedToInternet
        {
            self.onHandleInitData()
        }
        else
        {
            self.displayAlertNetWorkNotAvailable()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.onHandleInitData), name: NSNotification.Name.available, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
 
    
    func onHandleInitData()
    {
        self.messagesList.removeAll()
        self.loadingShow()
        UserInfoAPI.getMessage(completion: { (status:Bool, code:Int, results: [NSDictionary]?, totalPage:Int?) in
            if status
            {
                self.messagesList = results!
                DispatchQueue.main.async(execute: {
                    self.loadingHide()
                    self.messageTableView.reloadData()
                    print(self.messagesList)
                })
            }
            else
            {
                self.loadingHide()
            }
            
        })

    }

    @IBAction func onClickBack(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)        
    }

}

extension MessagesVC : UITableViewDataSource, UITableViewDelegate
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MessagesCell
        
        let item = messagesList[indexPath.row]
        
        cell.messageLabel.text = item["message"] as? String
        cell.dateLabel.text = convertDayMessage(DateString: item["creationDate"] as! String)
        
        if item["read"] as? String == ""
        {
            cell.backgroundColor = #colorLiteral(red: 0.9019607843, green: 0.9019607843, blue: 0.9019607843, alpha: 1)
            cell.messageLabel.font = UIFont.boldSystemFont(ofSize: 17)
            cell.dateLabel.font = UIFont.boldSystemFont(ofSize: 12)
        }
        else
        {
            cell.backgroundColor = .clear
            cell.messageLabel.font = UIFont.systemFont(ofSize: 17)
            cell.dateLabel.font = UIFont.systemFont(ofSize: 12)
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = messagesList[indexPath.row]
        if Connectivity.isConnectedToInternet
        {
            if item["read"] as? String == ""
            {
                self.loadingShow()
                DispatchQueue.global(qos: .default).async {
                    UserInfoAPI.readMessage(withToken: self.token!, identifier: self.messagesList[indexPath.row]["identifier"] as! Int) { (status:Bool, code:Int, results: NSDictionary?) in
                        
                        print(status,code,results as Any)
                        
                        if status
                        {
                            let messagedetailVC = UIStoryboard(name: PROFILE_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "messagedetailVC") as! MessageDetailsVC
                            messagedetailVC.messageDetail = self.messagesList[indexPath.row]
                            self.navigationController?.pushViewController(messagedetailVC, animated: true)
                            DispatchQueue.main.async(execute: {
                                self.loadingHide()
                                
                            })
                            
                        }
                        else if code == 401
                        {
                            self.loadingHide()
                            if let error = results?["error"] as? String
                            {
                                if error.contains("Token")
                                {
                                    DispatchQueue.main.async(execute: {
                                        self.onHandleTokenInvalidAlert()
                                    })
                                }
                            }
                            
                        }
                        else
                        {
                            DispatchQueue.main.async(execute: {
                                self.loadingHide()
                                
                            })
                        }
                        
                    }
                }
                
            }
            else
            {
                let messagedetailVC = UIStoryboard(name: PROFILE_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "messagedetailVC") as! MessageDetailsVC
                messagedetailVC.messageDetail = item
                self.navigationController?.pushViewController(messagedetailVC, animated: true)
                
            }

        }
        else
        {
            self.displayAlertNetWorkNotAvailable()
        }
        
        
    }
    
}










