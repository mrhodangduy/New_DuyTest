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
        self.loadingShow()
        UserInfoAPI.getMessage(withToken: self.token!) { (status:Bool, code:Int, results: [NSDictionary]?, totalPage:Int?) in
            
            if status
            {
                self.messagesList = results!
                DispatchQueue.main.async(execute: {
                    self.loadingHide()
                    self.messageTableView.reloadData()
                    print(self.messagesList)
                })
            }
        }
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
        cell.dateLabel.text = convertDay(DateString: item["creationDate"] as! String)
        
        if item["read"] as? String == ""
        {
            cell.backgroundColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
        }
        else
        {
            cell.backgroundColor = .clear
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.loadingShow()
        UserInfoAPI.readMessage(withToken: token!, identifier: messagesList[indexPath.row]["identifier"] as! Int) { (status:Bool, code:Int, results: NSDictionary?) in
            
            if status
            {
                DispatchQueue.main.async(execute: { 
                    self.loadingHide()
                    let messagedetailVC = UIStoryboard(name: PROFILE_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "messagedetailVC") as! MessageDetailsVC
                    messagedetailVC.messageDetail = self.messagesList[indexPath.row]
                    self.navigationController?.pushViewController(messagedetailVC, animated: true)
                    
                })
            }
            else
            {
                self.loadingHide()
            }
            
        }
    }
    
}










