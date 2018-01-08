//
//  Examiner_HomeVC.swift
//  Wodule
//
//  Created by QTS Coder on 10/2/17.
//  Copyright © 2017 QTS. All rights reserved.
//

import UIKit
import SDWebImage
import FBSDKLoginKit
import FacebookLogin
import SVProgressHUD
import Reachability
import AVFoundation

class Examiner_HomeVC: UIViewController {
    
    @IBOutlet weak var lbl_Name1: UILabel!
    @IBOutlet weak var lbl_Name2: UILabel!
    @IBOutlet weak var lbl_ExaminerID: UILabel!
    @IBOutlet weak var lbl_University: UILabel!
    @IBOutlet weak var lbl_Carier: UILabel!
    @IBOutlet weak var lbl_Sex: UILabel!
    @IBOutlet weak var lbl_Age: UILabel!
    @IBOutlet weak var img_Avatar: UIImageViewX!
    @IBOutlet weak var unreadLabel: UILabelX!
    
    var imageData: Data?
    var userInfomation:NSDictionary!
    var socialAvatar: URL!
    var socialIdentifier:String!
    
    var messagesList = [NSDictionary]()
    
    let token = userDefault.object(forKey: TOKEN_STRING) as? String
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if userDefault.object(forKey: SOCIALKEY) as? String != nil
        {
            socialIdentifier = userDefault.object(forKey: SOCIALKEY) as! String
        }
        else
        {
            socialIdentifier = NORMALLOGIN
        }
        
        print("\nCURRENT USER TOKEN: ------>\n", token!)
        print("\nCURRENT USER INFO: ------>\n", userInfomation)
        
        asignDataInView()
        
        userDefault.set(userInfomation["id"] as! Int, forKey: USERID_STRING)
        userDefault.synchronize()        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.unreadLabel.isHidden = true
        if Connectivity.isConnectedToInternet
        {
            DispatchQueue.global(qos: .default).async {
                UserInfoAPI.shared.getMessage(completion: { (status:Bool, code:Int, results: NSDictionary?, totalPage:Int?) in
                    if status
                    {
                        if let data = results?["data"] as? [NSDictionary]
                        {
                            self.messagesList.removeAll()
                            self.messagesList = data
                            self.messagesList = self.messagesList.filter({$0["read"] as? String == ""})
                            DispatchQueue.main.async(execute: {
                                self.unreadLabel.text = "\(self.messagesList.count)"
                                if self.messagesList.count > 0
                                {
                                    self.unreadLabel.isHidden = false
                                }
                                
                            })
                        }
                        
                    }
                    else if code == 401
                    {
                        self.onHandleTokenInvalidAlert()
                    }

                })
                
            }
        
        }
        else
        {
            self.displayAlertNetWorkNotAvailable()
        }
    }
   
    func asignDataInView()
    {        
        
        lbl_ExaminerID.text = "\((userInfomation["id"] as? Int)!)"
        lbl_Sex.text = userInfomation["gender"] as? String
        lbl_University.text = userInfomation["organization"] as? String
        lbl_Carier.text = userInfomation["student_class"] as? String
        
        print("IDENTIFIER:", socialIdentifier)

        switch socialIdentifier {
        case GOOGLELOGIN,FACEBOOKLOGIN,INSTAGRAMLOGIN:
            let avatar = userDefault.object(forKey: SOCIALAVATAR) as? String
            
            if userInfomation["picture"] as! String == "http://wodule.io/user/default.jpg" && avatar != nil
            {
                img_Avatar.sd_setImage(with: URL(string: avatar!), placeholderImage: nil, options: SDWebImageOptions.continueInBackground, completed: nil)
            }
            else
            {
                img_Avatar.sd_setImage(with: URL(string: userInfomation["picture"] as! String), placeholderImage: nil, options: SDWebImageOptions.continueInBackground, completed: nil)
            }
            
        case NORMALLOGIN:
            img_Avatar.sd_setImage(with: URL(string: userInfomation["picture"] as! String), placeholderImage: nil, options: SDWebImageOptions.continueInBackground, completed: nil)
        default:
            return
        }
        
        if userInfomation["ln_first"] as? String == "Yes"
        {
            lbl_Name1.text = userInfomation["last_name"] as? String
            lbl_Name2.text = (userInfomation["first_name"] as? String)
        }
        else
        {
            lbl_Name1.text = userInfomation["first_name"] as? String
            lbl_Name2.text = userInfomation["last_name"] as? String
        }
        
        if userInfomation["date_of_birth"] as? String != nil
        {
            let age = calAgeUser(dateString: (userInfomation["date_of_birth"] as? String)!)
            lbl_Age.text = age
        }
        else
        {
            lbl_Age.text = nil
        }
    }
    
    func loadNewData()
    {
        if Connectivity.isConnectedToInternet
        {
            DispatchQueue.global(qos: .default).async {
                UserInfoAPI.shared.getUserInfo(withToken: self.token!, completion: { (users) in
                    self.userInfomation = users!
                    DispatchQueue.main.async(execute: {
                        self.asignDataInView()
                        print("\nCURRENT USER INFO AFTER UPDATED:\n------>",self.userInfomation)
                        
                    })
                    
                })
            }

        }
        else
        {
//            self.displayAlertNetWorkNotAvailable()
        }
        
    }
    
    @IBAction func onClickMessage(_ sender: Any) {
        
        let messageVC = UIStoryboard(name: PROFILE_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "messageVC") as! MessagesVC
        self.navigationController?.pushViewController(messageVC, animated: true)

    }
    
    
    @IBAction func editProfile(_ sender: Any) {
        
        let editprofileVC = UIStoryboard(name: PROFILE_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "editprofileVC") as! EditProfileVC
        
        editprofileVC.userInfo = self.userInfomation
        editprofileVC.socialAvatar = self.socialAvatar
        editprofileVC.socialIdentifier = self.socialIdentifier
        editprofileVC.editDelegate = self
        
        self.navigationController?.pushViewController(editprofileVC, animated: true)
        
    }
    
    @IBAction func assessmentHistoryTap(_ sender: Any) {
        
        if Connectivity.isConnectedToInternet
        {
            let assessmenthistory = UIStoryboard(name: EXAMINEE_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "assessmenthistoryVC") as! AssessmentHistoryVC
            
            assessmenthistory.type = "records"
            assessmenthistory.userID = userInfomation["id"] as? Int
            
            self.navigationController?.pushViewController(assessmenthistory, animated: true)
        }
        else
        {
            self.displayAlertNetWorkNotAvailable()
        }
    }
    
    @IBAction func calendarTap(_ sender: Any) {
        if Connectivity.isConnectedToInternet
        {
            let calendarVC = UIStoryboard(name: EXAMINEE_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "calendarVC") as! CalendarVC
            self.navigationController?.pushViewController(calendarVC, animated: true)
        }
        else
        {
            self.displayAlertNetWorkNotAvailable()
        }
    }
    
    func onHandleDoExam()
    {
        let instruction_guideVC = UIStoryboard(name: EXAMINEE_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "instruction_guideVC") as! Instruction_GuideVC
        self.navigationController?.pushViewController(instruction_guideVC, animated: true)

    }
    
    @IBAction func startAssessmentTap(_ sender: Any) {
        if Connectivity.isConnectedToInternet
        {
            if AVAudioSession.sharedInstance().recordPermission() == AVAudioSessionRecordPermission.undetermined {
                AudioRecorderManager.shared.setup()
                
            } else if AVAudioSession.sharedInstance().recordPermission() == AVAudioSessionRecordPermission.granted {
                
                onHandleDoExam()
                
            } else {
                self.displayAlertMicroPermission()
                print("Denied")
            }            
        }
        else
        {
            self.displayAlertNetWorkNotAvailable()
        }
        
    }
    
    @IBAction func onClickLogOut(_ sender: Any) {
        
        let alert = UIAlertController(title: "Wodule", message: "Do you want to Sign Out?", preferredStyle: .alert)
        let okBtn = UIAlertAction(title: "Yes", style: .destructive) { (action) in
            
            self.onHandleLogOut()
        }
        
        let cancelBtn = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        alert.addAction(okBtn)
        alert.addAction(cancelBtn)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func onHandleLogOut()
    {
        switch socialIdentifier {
        case GOOGLELOGIN:
            GIDSignIn.sharedInstance().signOut()
            print("LogOut G+")
            
        case FACEBOOKLOGIN:
            let manger = FBSDKLoginManager()
            manger.logOut()
            print("LogOut FB")
            
        default:
            print("LogOut")
        }
        
        UserInfoAPI.shared.invalidToken(token: self.token!) { (status, result) in
            print(status, result as Any)
        }
        
        let loginVC = UIStoryboard(name: MAIN_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "loginVC") as! LoginVC
        
        let mainControler = MainNavigationController(rootViewController: loginVC)
        let window = UIApplication.shared.delegate!.window!!
        window.rootViewController = mainControler
        window.makeKeyAndVisible()
        
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
        
        userDefault.removeObject(forKey: SOCIALKEY)
        userDefault.removeObject(forKey: SOCIALAVATAR)
        userDefault.removeObject(forKey: TOKEN_STRING)
        AppDelegate.share.removeAllValueObject()
        userDefault.removeObject(forKey: USERNAMELOGIN)
        userDefault.removeObject(forKey: PASSWORDLOGIN)
        
        userDefault.synchronize()
    }
}

extension Examiner_HomeVC: EditProfileDelegate
{
    func updateDone() {
        self.loadNewData()
    }
}










