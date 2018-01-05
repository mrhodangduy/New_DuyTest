//
//  NewUser_Page3VC.swift
//  Wodule
//
//  Created by QTS Coder on 10/2/17.
//  Copyright © 2017 QTS. All rights reserved.
//

import UIKit
import Alamofire
import SVProgressHUD

class NewUser_Page3VC: UIViewController {
    
    @IBOutlet weak var tf_Status: UITextField!
    @IBOutlet weak var tf_Religion: UITextField!
    @IBOutlet weak var tf_Gender: UITextField!
    @IBOutlet weak var tf_Username: UITextField!
    @IBOutlet weak var tf_Password: UITextField!
    @IBOutlet weak var tf_Code: UITextField!
    
    @IBOutlet var dataTableView: UITableView!
    
    var backgroundView:UIView!
    var currentIndex: Int!
    
    var imgData:Data!
    
    var firstname:String!
    var lastname:String!
    var middlename:String!
    var birthday:String!
    var countryofBirth:String!
    var city:String!
    var country:String!
    var telephone:String!
    var nationality:String!
    var email:String!
    var status:String!
    var gender:String!
    var username:String!
    var password:String!
    var code:String!
    var native_name:String?
    var suffix: String?
    var address:String?
    var address1:String?
    var address2:String?
    var address3:String?
    var ethnicity:String?
    var religion:String?
    var ln_first:Bool?
    
    var para:Parameters!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataTableView.dataSource = self
        dataTableView.delegate = self
        
        tf_Gender.tintColor = .clear
        tf_Status.tintColor = .clear
        
        tf_Religion.delegate = self
        tf_Username.delegate = self
        tf_Password.delegate = self
        tf_Code.delegate = self
        
    }
    
    @IBAction func statusBtnTap(_ sender: Any) {
        self.endEditingView()

        currentIndex = 1
        setupViewData(subView: dataTableView, height: CGFloat(Status.count) * 44)
        createAnimatePopup(from: dataTableView, with: backgroundView)
        dataTableView.reloadData()
        
    }
    
    @IBAction func genderBtnTap(_ sender: Any) {
        
        self.endEditingView()
        currentIndex = 2
        setupViewData(subView: dataTableView, height: CGFloat(Gender.count) * 44)
        createAnimatePopup(from: dataTableView, with: backgroundView)
        dataTableView.reloadData()
        
    }
    
    
    @IBAction func backPageTap(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func resetBtnTap(_ sender: Any) {
        
        self.navigationController?.popToRootViewController(animated: true)
        
        
    }
    
    
    func getData()
    {
        firstname = userDefault.object(forKey: FIRSTNAME_STRING) as! String
        lastname = userDefault.object(forKey: LASTNAME_STRING) as! String
        middlename = userDefault.object(forKey: MIDDLENAME_STRING) as! String
        birthday = userDefault.object(forKey: BIRTHDAY_STRING) as! String
        countryofBirth = userDefault.object(forKey: COUNTRYOFBIRTH_STRING) as! String
        city = userDefault.object(forKey: CITY_STRING) as! String
        country = userDefault.object(forKey: COUNTRY_STRING) as! String
        telephone = userDefault.object(forKey: PHONE_STRING) as! String
        nationality = userDefault.object(forKey: NATIONALITY_STRING) as! String
        email = userDefault.object(forKey: EMAIL_STRING) as! String
        status = tf_Status.text
        gender = tf_Gender.text
        username = tf_Username.text
        password = tf_Password.text
        code = tf_Code.text
        native_name = userDefault.object(forKey: NATIVE_STRING) as? String ?? nil
        suffix = userDefault.object(forKey: SUFFIX_STRING) as? String ?? nil
        address1 = userDefault.object(forKey: ADDRESS1_STRING) as? String ?? nil
        address2 = userDefault.object(forKey: ADDRESS2_STRING) as? String ?? nil
        address3 = userDefault.object(forKey: ADDRESS3_STRING) as? String ?? nil
        ethnicity = userDefault.object(forKey: ETHNIC_STRING) as? String ?? nil
        ln_first = userDefault.bool(forKey: LASTNAMEFIRST_STRING)
        if tf_Religion.text?.characters.count == 0
        {
            religion = nil
        }
        else
        {
            religion = tf_Religion.text
        }
    }
    
    func createPara()
    {
        para = ["first_name":           firstname,
                "middle_name":          middlename,
                "last_name":            lastname,
                "date_of_birth":        birthday,
                "country_of_birth":     countryofBirth,
                "city":                 city,
                "country":              country,
                "telephone":            telephone,
                "nationality":          nationality,
                "status":               status,
                "gender":               gender,
                "email":                email,
                "user_name":            username,
                "password":             password,
                "code":                 code]
        
        if ln_first!
        {
            para.updateValue("Yes", forKey: "ln_first")
        }
        
        if (native_name?.trimmingCharacters(in: .whitespacesAndNewlines).characters.count)! > 0
        {
            para.updateValue(native_name!, forKey: "native_name")
        }
        if (suffix?.trimmingCharacters(in: .whitespacesAndNewlines).characters.count)! > 0
        {
            para.updateValue(suffix!, forKey: "suffix")
        }
        
        if (address1?.trimmingCharacters(in: .whitespacesAndNewlines).characters.count)! > 0
        {
            
            address = address1!
            
        }
        
        if (address2?.trimmingCharacters(in: .whitespacesAndNewlines).characters.count)! > 0
        {
            if address != nil
            {
                address = address! + ", " + address2!
                
            }
            else
            {
                address = address2!
                
            }
        }
        
        if (address3?.trimmingCharacters(in: .whitespacesAndNewlines).characters.count)! > 0
        {
            if address != nil
            {
                address = address! + ", " + address3!
                
            }
            else
            {
                address = address3!
                
            }
        }
        
        if address != nil
        {
            para.updateValue(address!, forKey: "address")
        }
        
        if (ethnicity?.trimmingCharacters(in: .whitespacesAndNewlines).characters.count)! > 0
        {
            para.updateValue(ethnicity!, forKey: "ethnicity")
        }
        
        if (tf_Religion.text?.characters.count)! > 0
        {
            para.updateValue(religion!, forKey: "religion")
        }
        
        print("\nPARA:----->",para)
    }

    
    @IBAction func submitBtnTap(_ sender: Any) {
        
        let checkey = checkValidateTextField(tf1: tf_Status, tf2: tf_Gender, tf3: tf_Username, tf4: tf_Password, tf5: tf_Code, tf6: nil)
        
        switch checkey {
        case 1:
            self.alertMissingText(mess: "Status is required", textField: nil)
        case 2:
            self.alertMissingText(mess: "Gender is required", textField: nil)
        case 3:
            self.alertMissingText(mess: "Username is required", textField: tf_Username)
        case 4:
            self.alertMissingText(mess: "Password is required", textField: tf_Password)
        case 5:
            self.alertMissingText(mess: "Code is required", textField: tf_Code)
        default:
            if Connectivity.isConnectedToInternet
            {
                getData()
                createPara()
                
                self.loadingShow()
                DispatchQueue.global().async {
                    UserInfoAPI.shared.RegisterUser(para: self.para, completion: { (status) in
                        
                        if status
                        {
                            self.removeValueObject()
                            let token = userDefault.object(forKey: TOKEN_STRING) as? String
                            userDefault.set(self.username, forKey: USERNAMELOGIN)
                            userDefault.set(self.password, forKey: PASSWORDLOGIN)
                            userDefault.synchronize()
                            
                            UserInfoAPI.shared.getUserInfo(withToken: token!, completion: { (userInfo) in
                                
                                if userInfo?["type"] as? String == UserType.assessor.rawValue
                                {
                                    let assessor_homeVC = UIStoryboard(name: ASSESSOR_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "assessor_homeVC") as! Assessor_HomeVC
                                    
                                    assessor_homeVC.userInfomation = userInfo
                                    
                                    self.navigationController?.pushViewController(assessor_homeVC, animated: true)
                                }
                                else
                                {
                                    let examiner_homeVC = UIStoryboard(name: EXAMINEE_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "examiner_homeVC") as! Examiner_HomeVC
                                    
                                    examiner_homeVC.userInfomation = userInfo
                                    
                                    self.navigationController?.pushViewController(examiner_homeVC, animated: true)
                                }
                                
                                DispatchQueue.main.async(execute: {
                                    self.loadingHide()
                                    print("REGISTER AND LOGIN SUCCESSFUL, REDIRECT TO:-->", (userInfo?["type"] as? String)?.uppercased() as Any)
                                })
                                
                            })
                        }
                        else
                        {
                            DispatchQueue.main.async(execute: {
                                self.loadingHide()
                                self.alertMissingText(mess: userDefault.object(forKey: NOTIFI_ERROR) as! String, textField: nil)
                            })
                        }
                        
                    })
                }

            }
            else
            {
                self.displayAlertNetWorkNotAvailable()
            }
            
            
        }
        
    }
    
    func setupViewData(subView: UIView, height: CGFloat)
    {
        backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        backgroundView.backgroundColor = UIColor.gray
        backgroundView.alpha = 0
        
        view.addSubview(backgroundView)
        view.addSubview(subView)
        subView.layer.cornerRadius = 10
        
        let widthView = view.frame.size.width * (18/20)
        let heightView:CGFloat = height
        subView.frame = CGRect(x: view.frame.size.width * (1/20), y: (view.frame.size.height - heightView) / 2 , width: widthView, height: heightView)
        subView.alpha = 0
    }
    
    func handleCloseView()
    {
        UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
            self.dataTableView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
            self.backgroundView.alpha = 0
            self.dataTableView.alpha = 0
        }, completion: { (true) in
            self.perform(#selector(self.removeView), with: self, afterDelay: 0)
            
        })
    }
    
    func removeView()
    {
        self.backgroundView.removeFromSuperview()
        self.dataTableView.removeFromSuperview()
        self.dataTableView.transform = .identity

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func removeValueObject()
    {
        userDefault.removeObject(forKey: FIRSTNAME_STRING)
        userDefault.removeObject(forKey: MIDDLENAME_STRING)
        userDefault.removeObject(forKey: LASTNAME_STRING)
        userDefault.removeObject(forKey: NATIVE_STRING)
        userDefault.removeObject(forKey: SUFFIX_STRING)
        userDefault.removeObject(forKey: LASTNAMEFIRST_STRING)
        userDefault.removeObject(forKey: BIRTHDAY_STRING)
        userDefault.removeObject(forKey: COUNTRYOFBIRTH_STRING)
        userDefault.removeObject(forKey: ADDRESS1_STRING)
        userDefault.removeObject(forKey: ADDRESS2_STRING)
        userDefault.removeObject(forKey: ADDRESS3_STRING)
        userDefault.removeObject(forKey: CITY_STRING)
        userDefault.removeObject(forKey: COUNTRY_STRING)
        userDefault.removeObject(forKey: EMAIL_STRING)
        userDefault.removeObject(forKey: PHONE_STRING)
        userDefault.removeObject(forKey: NATIONALITY_STRING)
        userDefault.removeObject(forKey: ETHNIC_STRING)
        userDefault.removeObject(forKey: STATUS_STRING)
        userDefault.removeObject(forKey: RELIGION_STRING)
        userDefault.removeObject(forKey: GENDER_STRING)
        userDefault.removeObject(forKey: USERNAME_STRING)
        userDefault.removeObject(forKey: PASSWORD_STRING)
        userDefault.removeObject(forKey: CODE_STRING)
        userDefault.removeObject(forKey: NOTIFI_ERROR)
        userDefault.synchronize()
        
        
    }

}

extension NewUser_Page3VC: UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 2
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NewUser3_TableViewCell
        
        if currentIndex == 1
        {
            cell.lbl_Name.text = Status[indexPath.row]
        }
        else
        {
            cell.lbl_Name.text = Gender[indexPath.row]
        }
        return cell
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if currentIndex == 1
        {
            self.tf_Status.text = Status[indexPath.row]
        }
        else
        {
            self.tf_Gender.text = Gender[indexPath.row]
        }
        
        handleCloseView()
    }
    
    
}

extension NewUser_Page3VC: UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case tf_Username:
            tf_Password.becomeFirstResponder()
        case tf_Password:
            tf_Code.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        
        return true
        
    }
}




