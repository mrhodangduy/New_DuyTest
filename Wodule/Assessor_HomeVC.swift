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

var autologin = false

class Assessor_HomeVC: UIViewController {
    
    @IBOutlet weak var lbl_Name1: UILabel!
    @IBOutlet weak var lbl_Name2: UILabel!
    @IBOutlet weak var lbl_AssessorID: UILabel!
    @IBOutlet weak var lbl_ResidenceAdd: UILabel!
    @IBOutlet weak var lbl_Carier: UILabel!
    @IBOutlet weak var lbl_Sex: UILabel!
    @IBOutlet weak var lbl_Age: UILabel!
    @IBOutlet weak var img_Avatar: UIImageViewX!
    
    var imageData:Data!
    var userInfomation:NSDictionary!
    var socialAvatar: URL!
    var socialIdentifier: String!

    
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.loadNewData), name: NSNotification.Name(rawValue: NOTIFI_UPDATED), object: nil)
        
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
            
            if userInfomation["picture"] as! String == "http://wodule.io/user/default.jpg"
            {
                img_Avatar.sd_setImage(with: socialAvatar, placeholderImage: nil, options: SDWebImageOptions.continueInBackground, completed: nil)
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
        loadingShow()
        DispatchQueue.global(qos: .default).async {
            UserInfoAPI.getUserInfo(withToken: self.token!, completion: { (users) in
                
                self.userInfomation = users!
                DispatchQueue.main.async(execute: {
                    self.asignDataInView()
                    self.loadingHide()
                    print("\nCURRENT USER INFO AFTER UPDATED: ------>\n",self.userInfomation)
                    
                })
                
            })
        }
    }
    
    @IBAction func assessmentHistoryTap(_ sender: Any) {
        
        
    }
    
    @IBAction func accountingTap(_ sender: Any) {
        
        let accountingVC = UIStoryboard(name: ASSESSOR_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "accountingVC") as! Assessor_AccountingVC
        self.navigationController?.pushViewController(accountingVC, animated: true)
        
    }
    
    @IBAction func calendarTap(_ sender: Any) {
        
        let calendarVC = UIStoryboard(name: ASSESSOR_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "calendarVC") as! Assessor_CalendarVC
        self.navigationController?.pushViewController(calendarVC, animated: true)
        
    }
    @IBAction func startAssessmentTap(_ sender: Any) {
        
        let allReocrdVC = UIStoryboard(name: ASSESSOR_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "allrecordVC") as! Assessor_AssessmentVC
        
        self.navigationController?.pushViewController(allReocrdVC, animated: true)

        
    }
    
    @IBAction func editProfile(_ sender: Any) {
        
        let editprofileVC = UIStoryboard(name: PROFILE_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "editprofileVC") as! EditProfileVC
        
        editprofileVC.socialAvatar = self.socialAvatar
        editprofileVC.socialIdentifier = self.socialIdentifier
        editprofileVC.userInfo = self.userInfomation
        
        self.navigationController?.pushViewController(editprofileVC, animated: true)
    }
    @IBAction func onClickLogOut(_ sender: Any) {
        
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
        
        if autologin
        {
            self.navigationController?.pushViewController(loginVC, animated: false)
        }
        else
        {
            self.navigationController?.popViewController(animated: false)
        }
        autologin = false
        userDefault.removeObject(forKey: TOKEN_STRING)
        userDefault.removeObject(forKey: SOCIALKEY)
        userDefault.removeObject(forKey: USERNAMELOGIN)
        userDefault.removeObject(forKey: PASSWORDLOGIN)
        AppDelegate.share.removeAllValueObject()
        userDefault.synchronize()
    }
}
