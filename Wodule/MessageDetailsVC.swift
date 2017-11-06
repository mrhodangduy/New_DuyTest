//
//  MessageDetailsVC.swift
//  Wodule
//
//  Created by QTS Coder on 11/6/17.
//  Copyright © 2017 QTS. All rights reserved.
//

import UIKit

class MessageDetailsVC: UIViewController {

    @IBOutlet weak var messageTextView: RoundTextView!
    
    var messageDetail:NSDictionary!
    override func viewDidLoad() {
        super.viewDidLoad()

        messageTextView.text = messageDetail["message"] as? String
        messageTextView.textContainerInset = UIEdgeInsetsMake(20, 20, 10, 10)
        
    }

    @IBAction func onClickBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
