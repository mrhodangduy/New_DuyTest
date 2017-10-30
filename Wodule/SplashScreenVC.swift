//
//  SplashScreenVC.swift
//  Wodule
//
//  Created by QTS Coder on 10/30/17.
//  Copyright © 2017 QTS. All rights reserved.
//

import UIKit

class SplashScreenVC: UIViewController {
    
    
    let username = userDefault.object(forKey: USERNAMELOGIN) as? String
    let password = userDefault.object(forKey: PASSWORDLOGIN) as? String
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("username:", username, "password:", password)
        self.perform(#selector(self.onHanldeAutoLogin), with: self, afterDelay: 1)

        
    }
    
    func onHanldeAutoLogin()
    {
        
        
        if username == nil && password == nil
        {
            let loginVC = UIStoryboard(name: MAIN_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "loginVC") as! LoginVC
            self.navigationController?.pushViewController(loginVC, animated: true)
            
            
        }
        else
        {
            self.onHandleLogin()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        super.navigationController?.isNavigationBarHidden = true
        
        print(userDefault.object(forKey: TOKEN_STRING) as? String as Any)
        print(userDefault.object(forKey: SOCIALKEY) as? String as Any)
        
    }
    
    func onHandleLogin()
    {
        DispatchQueue.global(qos: .default).async(execute: {
            UserInfoAPI.LoginUser(username: self.username!, password: self.password!, completion: { (status) in
                
                if status != nil && status!
                {
                    let token = userDefault.object(forKey: TOKEN_STRING) as? String
                    
                    UserInfoAPI.getUserInfo(withToken: token!, completion: { (userinfo) in
                        
                        if userinfo!["type"] as? String == UserType.assessor.rawValue
                        {
                            let assessor_homeVC = UIStoryboard(name: ASSESSOR_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "assessor_homeVC") as! Assessor_HomeVC
                            
                            assessor_homeVC.userInfomation = userinfo!
                            assessor_homeVC.autologin = true
                            
                            self.navigationController?.pushViewController(assessor_homeVC, animated: true)
                        }
                        else
                        {
                            let examiner_homeVC = UIStoryboard(name: EXAMINEE_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "examiner_homeVC") as! Examiner_HomeVC
                            
                            examiner_homeVC.userInfomation = userinfo!
                            examiner_homeVC.autologin = true
                            
                            self.navigationController?.pushViewController(examiner_homeVC, animated: true)
                        }
                        print("-----> LOGIN SUCCESSFUL")
                        
                    })
                    
                }
                else
                {
                   
                    print("-----> AUTOLOGIN FALED")
                    let loginVC = UIStoryboard(name: MAIN_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "loginVC") as! LoginVC
                    self.navigationController?.pushViewController(loginVC, animated: false)
                    
                }
                
            })
            
        })
    }
}
