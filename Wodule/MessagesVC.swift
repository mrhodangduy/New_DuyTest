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
        
        self.loadingShow()
        UserInfoAPI.getMessage(withToken: self.token!) { (status:Bool, code:Int, results: [NSDictionary]?, totalPage:Int?) in
            
            if status
            {
                self.messagesList = results!
                DispatchQueue.main.async(execute: { 
                    self.loadingHide()
                    self.messageTableView.reloadData()
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
        cell.dateLabel.text = item["creationDate"] as? String
        
        if item["read"] as? String == nil
        {
            cell.messageLabel.font = UIFont.boldSystemFont(ofSize: 15)
            cell.backgroundColor = #colorLiteral(red: 0.2779593766, green: 0.7153381705, blue: 0.4422388971, alpha: 1)
        }
        
        return cell
    }
}
