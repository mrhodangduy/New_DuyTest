//
//  Part1VC.swift
//  Wodule
//
//  Created by QTS Coder on 10/3/17.
//  Copyright © 2017 QTS. All rights reserved.
//

import UIKit
import JWGCircleCounter

class Part2VC: UIViewController {
    
    @IBOutlet weak var circleTime: JWGCircleCounter!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var recordingMess: UILabelX!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var tv_Data: UITextView!
    @IBOutlet weak var img_Photo: UIImageViewX!
    @IBOutlet weak var decreaseBtn: UIButtonX!
    @IBOutlet weak var increaseBtn: UIButtonX!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var controlTextView: UIView!
    @IBOutlet weak var controlImageView: UIView!
    
    var expectTime:TimeInterval = timeCoutdown
    var Exam:NSDictionary?
    var audio1_Data: Data?
    var audio2_Data: Data?
    
    let token = userDefault.object(forKey: TOKEN_STRING) as? String
    
    let userID = userDefault.object(forKey: USERID_STRING) as? Int
    var examID:Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AudioRecorderManager.shared.recorder?.prepareToRecord()
        circleTime.circleBackgroundColor = .clear
        circleTime.circleColor = .white
        circleTime.circleTimerWidth = 2
        circleTime.delegate = self
        recordingMess.isHidden = true
        nextBtn.isHidden = true
        
        img_Photo.isHidden = true
        tv_Data.isHidden = true
        
        if Exam?["question_2"] as? String == nil
        {
            lbl_Title.text = TITLEPHOTO
            img_Photo.isHidden = false
            controlTextView.isHidden = true
            controlImageView.isHidden = false
            img_Photo.contentMode = .scaleAspectFit
            img_Photo.sd_setIndicatorStyle(.white)
            img_Photo.sd_showActivityIndicatorView()
            img_Photo.sd_setShowActivityIndicatorView(true)
            img_Photo.sd_setImage(with: URL(string: Exam?["image_2"] as! String), placeholderImage: nil, options: [.continueInBackground]) { (iamge, error, type, url) in
                
                self.circleTime.start(withSeconds: timeInitial)
            }
        }
        else
        {
            lbl_Title.text = TITLESTRING
            controlTextView.isHidden = false
            controlImageView.isHidden = true
            tv_Data.isHidden = false
            tv_Data.textContainerInset = UIEdgeInsetsMake(20, 20, 10, 10)
            tv_Data.text = Exam?["question_2"] as! String
            circleTime.start(withSeconds: timeInitial)
            
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.onHandleUploadAfterConnectAgain), name: NSNotification.Name.available, object: nil)
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tv_Data.isScrollEnabled = false
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tv_Data.isScrollEnabled = true
        
    }
    
    @IBAction func decreaseSizeTap(_ sender: Any) {
        
        tv_Data.decreaseFontSize()
    }
    
    @IBAction func increaseSizeTap(_ sender: Any) {
        
        tv_Data.increaseFontSize()
    }
    
    @IBAction func onClickPromt(_ sender: Any) {
        
        if Exam?["image_2"] as? String != nil
        {
            let button = sender as! UIButton
            switch button.tag {
            case 1:
                let promt_1 = Exam?["promt2_1"] as? String
                self.alert_PromtQuestion(title: "", mess: promt_1)
                button.setTitle("", for: .normal)
                button.isEnabled = false
            case 2:
                let promt_2 = Exam?["promt2_2"] as? String
                self.alert_PromtQuestion(title: "", mess: promt_2)
                button.setTitle("", for: .normal)
                button.isEnabled = false
            case 3:
                let promt_3 = Exam?["promt2_3"] as? String
                self.alert_PromtQuestion(title: "", mess: promt_3)
                button.setTitle("", for: .normal)
                button.isEnabled = false
            default:
                return
            }
            
        }
    }
    
    @IBAction func nextBtnTap(_ sender: Any) {
        
        if Connectivity.isConnectedToInternet
        {
            if Exam?["question_3"] as? String == nil && Exam?["image_3"] as? String == nil
            {
                let endVC = UIStoryboard(name: EXAMINEE_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "endassessmentVC") as! EndVC
                self.navigationController?.pushViewController(endVC, animated: true)
            }
            else
            {
                let part3_tempVC = UIStoryboard(name: EXAMINEE_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "part3_tempVC") as! Part3VC
                
                part3_tempVC.Exam = self.Exam
                part3_tempVC.examID = self.examID
                part3_tempVC.audio1_Data = self.audio1_Data
                part3_tempVC.audio2_Data = self.audio2_Data
                
                self.navigationController?.pushViewController(part3_tempVC, animated: true)
            }        }
        else
        {
            self.displayAlertNetWorkNotAvailable()
        }
        

    }
    
    func onHandleUploadSuccessful(mess: String?)
    {
        let alert = UIAlertController(title: "Wodule", message: mess, preferredStyle: .alert)
        let btnOK = UIAlertAction(title: "OK", style: .default) { (action) in
            print("OK")
        }
        
        alert.addAction(btnOK)
        self.present(alert, animated: true, completion: nil)
    }
    
    func onHandleUploadError(mess: String?, audio2data: Data?)
    {
        let alert = UIAlertController(title: "Wodule", message: mess, preferredStyle: .alert)
        let btnTryagain = UIAlertAction(title: "Try Again", style: .destructive) { (action) in
            
            print("Try again")
            self.onHandleUploadExam(audio2data: audio2data)
        }
        
        alert.addAction(btnTryagain)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    @objc func onHandleUploadExam(audio2data: Data?)
    {
        if self.presentedViewController != nil {
            self.dismiss(animated: false, completion: nil)
        }
        if Connectivity.isConnectedToInternet
        {
            self.loadingShowwithStatus(status: "Uploading...")
            DispatchQueue.global(qos: .default).async {
                ExamRecord.uploadExam(withToken: self.token!, idExam: self.examID, audiofile1: self.audio1_Data, audiofile2:audio2data, audiofile3: nil, audiofile4: nil, completion: { (status:Bool?, result:NSDictionary?) in
                    
                    let message = result?["message"] as? String
                    
                    if status == true
                    {
                        self.nextBtn.isHidden = false
                        DispatchQueue.main.async(execute: {
                            self.loadingHide()
                            self.onHandleUploadSuccessful(mess: message)
                            
                        })
                    }
                    else if status == false
                    {
                        DispatchQueue.main.async(execute: {
                            self.loadingHide()
                            self.onHandleUploadError(mess: message, audio2data: audio2data)
                        })
                    }
                    else
                    {
                        print("Uploading")
                    }
                })
            }

        }
        else
        {
            self.displayAlertNetWorkNotAvailable()
        }
        
    }
    
    func onHandleUploadAfterConnectAgain()
    {
        self.loadingShowwithStatus(status: "Uploading your Exam.")
        DispatchQueue.global(qos: .default).async {
            ExamRecord.uploadExam(withToken: self.token!, idExam: self.examID, audiofile1: self.audio1_Data, audiofile2:self.audio2_Data, audiofile3: nil, audiofile4: nil, completion: { (status:Bool?, result:NSDictionary?) in
                
                let message = result?["message"] as? String
                
                if status == true
                {
                    self.nextBtn.isHidden = false
                    DispatchQueue.main.async(execute: {
                        self.loadingHide()
                        self.onHandleUploadSuccessful(mess: message)
                        
                    })
                }
                else if status == false
                {
                    DispatchQueue.main.async(execute: {
                        self.loadingHide()
                        self.onHandleUploadError(mess: message, audio2data: self.audio2_Data)
                    })
                }
                else
                {
                    print("Uploading")
                }
            })
        }

    }
    
    
}

extension Part2VC: JWGCircleCounterDelegate
{
    func circleCounterTimeDidExpire(_ circleCounter: JWGCircleCounter!) {
        
        var audioURL:NSURL?
        self.StarRecording(userID: userID!, examID: examID, audio: 2) { (audioURLs:NSURL?) in
            audioURL = audioURLs
        }
        
        self.recordingMess.isHidden = false
        UIView.animate(withDuration: expectTime, animations: {
            self.viewBackground.frame.size.width = self.containerView.frame.size.width
            self.view.layoutIfNeeded()
        }, completion: { (done) in
            self.recordingMess.text = "Time Out"
            self.stopRecord()
            do
            {
                self.audio2_Data = try? Data(contentsOf: audioURL! as URL)
                if self.Exam?["question_3"] as? String == nil && self.Exam?["image_3"] as? String == nil
                {
                    self.onHandleUploadExam(audio2data: self.audio2_Data)
                }
                else
                {
                    self.nextBtn.isHidden = false
                }
            }
        })
        
    }
}











