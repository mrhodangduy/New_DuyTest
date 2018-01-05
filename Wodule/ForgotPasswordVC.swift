//
//  ForgotPasswordVC.swift
//  Wodule
//
//  Created by QTS Coder on 10/2/17.
//  Copyright © 2017 QTS. All rights reserved.
//

import UIKit

class ForgotPasswordVC: UIViewController {
    
    @IBOutlet weak var tf_Username: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tf_Username.delegate = self
        
    }
    @IBAction func onClickCancel(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submitBtnTap(_ sender: Any) {
        
        self.endEditingView()
        let checkey = checkValidateTextField(tf1: tf_Username, tf2: nil, tf3: nil, tf4: nil, tf5: nil, tf6: nil)
        
        switch checkey {
        case 1:
            self.alertMissingText(mess: "Email is required", textField: tf_Username)
            
        default:
            
            if !isValidEmail(testStr: tf_Username.text!)
            {
                self.alertMissingText(mess: "The email must be a valid email address.", textField: tf_Username)
            }
            else
            {
                if Connectivity.isConnectedToInternet
                {
                    self.loadingShow()
                    DispatchQueue.global(qos: .default).async(execute: {
                        
                        UserInfoAPI.shared.ResetPassword(email: self.tf_Username.text!, completion: { (status:Bool?, result:NSDictionary?) in
                            
                            if status!
                            {
                                if let data = result?["data"] as? NSDictionary
                                {
                                    let mess = data.object(forKey: "success") as? String
                                    DispatchQueue.main.async(execute: {
                                        self.loadingHide()
                                        self.alertSuccessful(mess: mess!)
                                    })
                                }
                                    
                                else
                                {
                                    DispatchQueue.main.async {
                                        self.loadingHide()
                                        print("ERROR", result as Any)
                                    }
                                }
                            }
                            else
                            {
                                if let error = result?.object(forKey: "message") as? String
                                {
                                    DispatchQueue.main.async(execute: {
                                        self.loadingHide()
                                        self.alertMissingText(mess: error, textField: self.tf_Username)
                                    })
                                }
                                else
                                {
                                    DispatchQueue.main.async {
                                        self.loadingHide()
                                        print("ERROR", result as Any)
                                    }
                                    
                                }
                            }
                            
                        })
                        
                    })
                }
                else{
                    self.displayAlertNetWorkNotAvailable()
                }
                
            }
        }
        
    }
    
    func alertSuccessful(mess: String)
    {
        let alert = UIAlertController(title: "Wodule", message: mess, preferredStyle: .alert)
        let OKBtn = UIAlertAction(title: "OK", style: .default) { (action) in
            
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(OKBtn)
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension ForgotPasswordVC: UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}



