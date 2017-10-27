//
//  Assessor_AccountingVC.swift
//  Wodule
//
//  Created by QTS Coder on 10/4/17.
//  Copyright © 2017 QTS. All rights reserved.
//

import UIKit

class Assessor_AccountingVC: UIViewController {
    
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var availableLabel: UILabel!
    
    @IBOutlet weak var totalLBL: UILabel!
    @IBOutlet weak var balanceLBL: UILabel!
    @IBOutlet weak var availabelLBL: UILabel!
    
    var Accounting: NSDictionary?
    let token = userDefault.object(forKey: TOKEN_STRING) as? String
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        totalLBL.isHidden = true
        balanceLBL.isHidden = true
        availabelLBL.isHidden = true
        
        self.loadingShow()
        ManageAPI_Accounting.getAccounting(witkToken: token!) { (status: Bool, result:NSDictionary?) in
            
            if status
            {
                self.Accounting = result!
                DispatchQueue.main.async(execute: {
                    self.onHandleAssignData()
                    self.loadingHide()
                    
                })
            }
                
            else
            {
                
                self.loadingHide()
                self.alertMissingText(mess: "Something went wrong.", textField: nil)
                print(result)
                
            }
            
            
        }
        
        // Do any additional setup after loading the view.
    }
    
    func onHandleAssignData()
    {
        
        totalLBL.isHidden = false
        balanceLBL.isHidden = false
        availabelLBL.isHidden = false
        
        var totalCash = ""
        var balanceCash = ""
        var availabelCash = ""
        
        if Accounting?["totalCash"] as! String == ""
        {
            totalCash = "0"
        }
        else
        {
            totalCash = Accounting?["totalCash"] as! String
        }
        if Accounting?["balanceCash"] as! String == ""
        {
            balanceCash = "0"
        }
        else
        {
            balanceCash = Accounting?["balanceCash"] as! String
        }
        if Accounting?["availableCash"] as! String == ""
        {
            availabelCash = "0"
        }
        else
        {
            availabelCash = Accounting?["availableCash"] as! String
        }
        
        totalLabel.text = "\(Accounting?["currency"] as! String)" + totalCash
        balanceLabel.text = "\(Accounting?["currency"] as! String)" + balanceCash
        availableLabel.text = "\(Accounting?["currency"] as! String)" + availabelCash
        
    }
    
    @IBAction func backtoHomeTap(_ sender: Any) {
        
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers
        for assessor_homeVC in viewControllers {
            if assessor_homeVC is Assessor_HomeVC {
                self.navigationController!.popToViewController(assessor_homeVC, animated: true)
            }
        }
        
    }
    
}
