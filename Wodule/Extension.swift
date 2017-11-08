//
//  Extension.swift
//  Wodule
//
//  Created by QTS Coder on 10/2/17.
//  Copyright © 2017 QTS. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD

extension Notification.Name
{
    static let none = Notification.Name("none")
    static let available = Notification.Name("available")
    
}

extension UITextView {
    func increaseFontSize () {
        self.font =  UIFont(name: (self.font?.fontName)!, size: (self.font?.pointSize)!+1)!
    }
    func decreaseFontSize () {
        
        if (self.font?.pointSize)! < CGFloat(10)
        {
            return
        }
        
        self.font =  UIFont(name: (self.font?.fontName)!, size: (self.font?.pointSize)!-1)!
        
    }
}


extension UIViewController
{
    
    func endEditingView()
    {
        self.view.endEditing(true)
    }
    
    func listFilesFromDocumentsFolder() -> [String]?
    {
        let fileMngr = FileManager.default;
        
        // Full path to documents directory
        let docs = fileMngr.urls(for: .documentDirectory, in: .userDomainMask)[0].path
        
        
        // List all contents of directory and return as [String] OR nil if failed
        return try? fileMngr.contentsOfDirectory(atPath:docs)
        
    }
    

    func StarRecording(userID: Int, examID: Int,audio: Int, result: (_ audioURL: NSURL?) -> Void)
    {
        
        AudioRecorderManager.shared.recored(fileName: "Recordedby-\(userID)-forExam-\(examID)-audio\(audio)") { (status:Bool, audioURL:NSURL?) in
            
            if status == true
            {
                print("Did start recording")
                
            }
            else
            {
                print("Error starting recorder")
            }
            
            result(audioURL)
        }
    }
    
    func stopRecord()
    {
        AudioRecorderManager.shared.finishRecording()
    }
    
    func loadingShowwithStatus(status: String)
    {
        SVProgressHUD.show(withStatus: status)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        SVProgressHUD.setDefaultAnimationType(SVProgressHUDAnimationType.flat)
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.clear)
    }
    
    func loadingShow()
    {
        SVProgressHUD.show()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        SVProgressHUD.setDefaultAnimationType(SVProgressHUDAnimationType.flat)
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.clear)
    }
    func loadingHide()
    {
        SVProgressHUD.dismiss()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.none)

    }
    
    func play_pauseAudio(button:UIButton, isPlay:Bool)
    {
        if isPlay
        {
            button.setImage(#imageLiteral(resourceName: "btn_play"), for: .normal)
        }
        else
        {
            button.setImage(#imageLiteral(resourceName: "btn_pause"), for: .normal)
        }
    }
    
    func expand_collapesView(button:UIButton,viewHeight: NSLayoutConstraint,isExpanding: Bool, originalHeight: CGFloat)
    {
        if isExpanding
        {
            button.setBackgroundImage(#imageLiteral(resourceName: "btn_keyup"), for: .normal)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [.allowUserInteraction], animations: {
                viewHeight.constant = 10
                self.view.layoutIfNeeded()
            }, completion: nil  )
        }
        else
        {
            button.setBackgroundImage(#imageLiteral(resourceName: "btn_keydown"), for: .normal)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [.allowUserInteraction], animations: {
                viewHeight.constant = originalHeight
                self.view.layoutIfNeeded()
            }, completion: nil  )
        }
        
    }
    
    func createAnimatePopup(from mainView: UIView, with backGroundView: UIView)
    {
        
        mainView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        backGroundView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        
        UIView.animate(withDuration: 0.2, animations: {
            mainView.transform = .identity
            backGroundView.transform = .identity
        }, completion: nil)
        
        backGroundView.backgroundColor = UIColor.black
        backGroundView.alpha = 0.8
        mainView.alpha = 1
        
    }
    
    func checkValidateTextField(tf1: UITextField? ,tf2: UITextField?,tf3: UITextField?,tf4: UITextField?,tf5: UITextField?,tf6: UITextField?) -> Int
    {
        
        if tf1?.text?.characters.count == 0
        {
            return 1
        }
        else if tf2?.text?.characters.count == 0
        {
            return 2
        }
        else if tf3?.text?.characters.count == 0
        {
            return 3
        }
        else if tf4?.text?.characters.count == 0
        {
            return 4
        }
        else if tf5?.text?.characters.count == 0
        {
            return 5
        }
        else if tf6?.text?.characters.count == 0
        {
            return 6
        }
        else
        {
            return 0
            
        }
    }
    
    func onHandleTokenInvalidAlert()
    {
        let alert = UIAlertController(title: "Wodule", message: "Your session has expired.\nPlease Login again.", preferredStyle: .alert)
        let btnOK = UIAlertAction(title: "OK", style: .default) { (action) in
            
            let loginVC = UIStoryboard(name: MAIN_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "loginVC") as! LoginVC
            let mainControler = MainNavigationController(rootViewController: loginVC)
            let window = UIApplication.shared.delegate!.window!!
            window.rootViewController = mainControler
            window.makeKeyAndVisible()
            
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
            
        }
        alert.addAction(btnOK)
        self.present(alert, animated: true, completion: nil)
    }
    
    func alertMissingText(mess: String, textField: UITextField?)
        
    {
        let alert = UIAlertController(title: "Wodule", message: mess, preferredStyle: .alert)
        let btnOK = UIAlertAction(title: "OK", style: .default) { (action) in
            textField?.becomeFirstResponder()
        }
        
        alert.addAction(btnOK)
        self.present(alert, animated: true, completion: nil)
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: testStr)
        return result
    }
    
    func calAgeUser(dateString: String) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateofBirth = dateFormatter.date(from: dateString)
        
        let today = Date()
        let calendar = Calendar.current
        let ageCompoment = calendar.dateComponents([.year], from: dateofBirth!, to: today)
        
        if ageCompoment.year == 0
        {
            return "\(ageCompoment.year! + 1)"
            
        }
        else
        {
            return "\(ageCompoment.year!)"
            
        }
    }
    
    func convertDayHistory(DateString: String) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.date(from: DateString)
        dateFormatter.dateFormat = "yy.MM.dd"
        return dateFormatter.string(from: date!)
    }
    
    func convertDayMessage(DateString: String) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.date(from: DateString)
        dateFormatter.dateFormat = "MMM dd HH:mm"
        return dateFormatter.string(from: date!)
    }
    
    func convertDayEvent(DateString: String) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.date(from: DateString)
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter.string(from: date!)
    }
    func convertTimeEvent(DateString: String) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.date(from: DateString)
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: date!)
    }
    
    func alert_PromtQuestion(title: String?,mess: String?)
        
    {
        let alert = UIAlertController(title: title, message: mess, preferredStyle: .alert)
        let btnOK = UIAlertAction(title: "Close", style: .default, handler: nil)
        alert.addAction(btnOK)
        self.present(alert, animated: true, completion: nil)
    }
    
    func openSetting()
    {
        
        let urlStrings = ["prefs:root=Settings", "App-Prefs:root=Settings"]
        for urlString: String in urlStrings {
            guard let url = URL(string: urlString) else {return}
            if UIApplication.shared.canOpenURL(url)
            {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    
                } else {
                    UIApplication.shared.openURL(url)
                    
                }
                break
            }            
        }
        
    }
    
    func displayAlertNetWorkNotAvailable()
    {
        let alert = UIAlertController(title: "Wodule", message: "No internet connection available.", preferredStyle: .alert)
        let openSettingBtn = UIAlertAction(title: "Settings", style: .default) { (action) in
            
            self.openSetting()
            
        }
        let OKbtn = UIAlertAction(title: "OK", style: .default) { (okAction) in
            
        }
        alert.addAction(openSettingBtn)
        alert.addAction(OKbtn)
        self.present(alert, animated: true, completion: nil)
    }
    
}
