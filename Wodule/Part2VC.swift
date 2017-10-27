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
    
    var expectTime:TimeInterval = timeCoutdown
    var Exam:NSDictionary?
    var audio1_Path: NSURL?
    var audio2_Path: NSURL?
    
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
            decreaseBtn.isHidden = true
            increaseBtn.isHidden = true
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
            tv_Data.isHidden = false
            tv_Data.text = Exam?["question_2"] as! String
            circleTime.start(withSeconds: timeInitial)
            
        }

        
        
        
    }
    
    @IBAction func decreaseSizeTap(_ sender: Any) {
        
        tv_Data.decreaseFontSize()
    }
    
    @IBAction func increaseSizeTap(_ sender: Any) {
        
        tv_Data.increaseFontSize()
    }
    
    @IBAction func nextBtnTap(_ sender: Any) {
        
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
            part3_tempVC.audio1_Path = self.audio1_Path
            part3_tempVC.audio2_Path = self.audio2_Path
            
            self.navigationController?.pushViewController(part3_tempVC, animated: true)
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
            self.audio2_Path = audioURL

            if self.Exam?["question_3"] as? String == nil && self.Exam?["image_3"] as? String == nil
            {
                self.loadingShowwithStatus(status: "Uploading your Exam.")                
                do
                {
                    let data1 = try? Data(contentsOf: self.audio1_Path! as URL)
                    let data2 = try? Data(contentsOf: self.audio2_Path! as URL)
                    ExamRecord.uploadExam(withToken: self.token!, idExam: self.examID, audiofile1: data1, audiofile2: data2, audiofile3: nil, audiofile4: nil, completion: { (status:Bool?, result:NSDictionary?) in
                        if status!
                        {
                            DispatchQueue.main.async(execute: {
                                self.loadingHide()
                                self.nextBtn.isHidden = false
                            })
                        }
                    })
                }
                
            }
            else
            {
                self.nextBtn.isHidden = false
            }
            
        })
        
    }
}











