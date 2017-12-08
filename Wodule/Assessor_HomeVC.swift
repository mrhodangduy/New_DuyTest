//
//  Assessor_HomeVC.swift
//  Wodule
//
//  Created by QTS Coder on 10/2/17.
//  Copyright © 2017 QTS. All rights reserved.
//

import UIKit
import SDWebImage
import SVProgressHUD
import FBSDKLoginKit
import FacebookLogin


class Assessor_HomeVC: UIViewController {
    
    @IBOutlet weak var lbl_Name1: UILabel!
    @IBOutlet weak var lbl_Name2: UILabel!
    @IBOutlet weak var lbl_AssessorID: UILabel!
    @IBOutlet weak var lbl_ResidenceAdd: UILabel!
    @IBOutlet weak var lbl_Carier: UILabel!
    @IBOutlet weak var lbl_Sex: UILabel!
    @IBOutlet weak var lbl_Age: UILabel!
    @IBOutlet weak var img_Avatar: UIImageViewX!
    @IBOutlet weak var unreadLabel: UILabelX!
    
    var imageData:Data!
    var userInfomation:NSDictionary!
    var socialAvatar: URL!
    var socialIdentifier: String!
    
    var messagesList = [NSDictionary]()
    
    var CategoryList = [Categories]()
    
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
        print("\nCURRENT USER INFO: ------>\n",userInfomation)
        print("\nCURRENT USER AVATARLINK: ------>\n",socialAvatar)
        
        asignDataInView()        
        
        
    }    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.unreadLabel.isHidden = true
        if Connectivity.isConnectedToInternet
        {
            DispatchQueue.global(qos: .background).async {
                UserInfoAPI.getMessage(completion: { (status:Bool, code:Int, results: NSDictionary?, totalPage:Int?) in
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
                                print(self.messagesList)
                                
                            })

                        }
                        
                    }
                    else if code == 401
                    {
                        self.onHandleTokenInvalidAlert()
                    }
                    else
                    {
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
        lbl_AssessorID.text = "\((userInfomation["id"] as? Int)!)"
        lbl_Sex.text = userInfomation["gender"] as? String
        lbl_ResidenceAdd.text = userInfomation["organization"] as? String
        lbl_Carier.text = userInfomation["student_class"] as? String
        
        print("IDENTIFIER:", socialIdentifier)
        
        switch socialIdentifier {
            
        case GOOGLELOGIN,FACEBOOKLOGIN, INSTAGRAMLOGIN:
            
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
            lbl_Name2.text = userInfomation["first_name"] as? String
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
                UserInfoAPI.getUserInfo(withToken: self.token!, completion: { (users) in
                    
                    self.userInfomation = users!
                    DispatchQueue.main.async(execute: {
                        self.asignDataInView()
                        print("\nCURRENT USER INFO AFTER UPDATED: ------>\n",self.userInfomation)
                        
                    })
                    
                })
            }
        }
        
    }
    
    @IBAction func assessmentHistoryTap(_ sender: Any) {
        if Connectivity.isConnectedToInternet
        {
            let assessmentrecordVC = UIStoryboard(name: ASSESSOR_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "assessmentrecordVC") as! Assessor_AssessmentRecordVC
            self.navigationController?.pushViewController(assessmentrecordVC, animated: true)
            
            
            
//            let assessmenthistory = UIStoryboard(name: EXAMINEE_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "assessmenthistoryVC") as! AssessmentHistoryVC
//            assessmenthistory.type = "grades"
//            assessmenthistory.userID = userInfomation["id"] as? Int
//            self.navigationController?.pushViewController(assessmenthistory, animated: true)

        }
        else
        {
            self.displayAlertNetWorkNotAvailable()
        }
        
    }
    
    @IBAction func accountingTap(_ sender: Any) {
        if Connectivity.isConnectedToInternet
        {
            let accountingVC = UIStoryboard(name: ASSESSOR_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "accountingVC") as! Assessor_AccountingVC

            self.navigationController?.pushViewController(accountingVC, animated: true)
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
    @IBAction func startAssessmentTap(_ sender: Any) {
        
        if Connectivity.isConnectedToInternet
        {
            self.loadingShow()
            ExamRecord.getAllRecord(completion: { (records: [NSDictionary]?, code: Int?, error: NSDictionary?) in
                print(records as Any)
                if let exams = records
                {
                    let exam = exams[0]
                    DispatchQueue.main.async {
                        let part1VC = UIStoryboard(name: ASSESSOR_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "gradeVC") as! Assessor_GradeVC
                        
                        part1VC.Exam = exam
                        print(exam)
                        let identifier = exam["identifier"] as? Int
                        userDefault.set(identifier, forKey: IDENTIFIER_KEY)
                        userDefault.synchronize()
                        self.navigationController?.pushViewController(part1VC, animated: true)
                    }
                } else if code == 200
                {
                    DispatchQueue.main.async {
                        self.alertMissingText(mess: "No exam to grade.", textField: nil)
                    }
                } else if error?["code"] as! Int == 429
                {
                    if let errorMess = (error?["error"] as? String)
                    {
                        DispatchQueue.main.async(execute: {
                            self.loadingHide()
                            self.alertMissingText(mess: "\(errorMess)\n(ErrorCode:\(error?["code"] as! Int))", textField: nil)
                        })
                    } else {
                        DispatchQueue.main.async(execute: {
                            self.loadingHide()
                            self.alertMissingText(mess: "Server error. Try again later.", textField: nil)
                        })

                    }
                }
                else if code == 401
                {
                    if let error = error?["error"] as? String
                    {
                        if error.contains("Token")
                        {
                            self.loadingHide()
                            self.onHandleTokenInvalidAlert()
                        }
                    }
                }
            })
        }
        else
        {
            self.displayAlertNetWorkNotAvailable()
        }
        
    }
    
    @IBAction func onClickMessage(_ sender: Any) {
        
        if Connectivity.isConnectedToInternet
        {
            let messageVC = UIStoryboard(name: PROFILE_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "messageVC") as! MessagesVC
            self.navigationController?.pushViewController(messageVC, animated: true)
        }
        else
        {
            self.displayAlertNetWorkNotAvailable()
        }
        
    }
    
    
    @IBAction func editProfile(_ sender: Any) {
        
        if Connectivity.isConnectedToInternet
        {
            let editprofileVC = UIStoryboard(name: PROFILE_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "editprofileVC") as! EditProfileVC
            
            editprofileVC.socialAvatar = self.socialAvatar
            editprofileVC.socialIdentifier = self.socialIdentifier
            editprofileVC.userInfo = self.userInfomation
            editprofileVC.editDelegate = self
            self.navigationController?.pushViewController(editprofileVC, animated: true)
        }
        else
        {
            self.displayAlertNetWorkNotAvailable()
        }
        
    }
    @IBAction func onClickLogOut(_ sender: Any) {
        
        let alert = UIAlertController(title: "Wodule", message: "Do you want to log out?", preferredStyle: .alert)
        let okBtn = UIAlertAction(title: "OK", style: .default) { (action) in
            
            self.onHandleLogOut()
        }
        
        let cancelBtn = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
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
            print("LogOut Normal")
        }
        
        let loginVC = UIStoryboard(name: MAIN_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "loginVC") as! LoginVC
        
        let mainControler = MainNavigationController(rootViewController: loginVC)
        let window = UIApplication.shared.delegate!.window!!
        window.rootViewController = mainControler
        window.makeKeyAndVisible()
        
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
        userDefault.removeObject(forKey: TOKEN_STRING)
        userDefault.removeObject(forKey: SOCIALKEY)
        userDefault.removeObject(forKey: SOCIALAVATAR)
        userDefault.removeObject(forKey: USERNAMELOGIN)
        userDefault.removeObject(forKey: PASSWORDLOGIN)
        AppDelegate.share.removeAllValueObject()
        userDefault.synchronize()
    }
}

extension Assessor_HomeVC: EditProfileDelegate
{
    func updateDone() {
        self.loadNewData()
    }
}









