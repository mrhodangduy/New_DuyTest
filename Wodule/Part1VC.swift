//
//  Part2VC.swift
//  Wodule
//
//  Created by QTS Coder on 10/3/17.
//  Copyright © 2017 QTS. All rights reserved.
//

import UIKit
import JWGCircleCounter


class Part1VC: UIViewController {
    
    @IBOutlet weak var circleTime: JWGCircleCounter!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var lbl_CountdownTime: UILabel!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var viewbackground: UIView!
    @IBOutlet weak var image_Question: UIImageViewX!
    @IBOutlet weak var tv_Data: UITextView!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var decreaseBtn: UIButtonX!
    @IBOutlet weak var increaseBtn: UIButtonX!
    @IBOutlet weak var recordingMess: UILabelX!
    @IBOutlet weak var controlTextView: UIView!
    @IBOutlet weak var controlImageView: UIView!
    
    var Exam:NSDictionary?
    var audio1_Data: Data?
    var audioURL:NSURL?
    var isNext = false
    var time:Timer!
    var expectTime:TimeInterval = timeCoutdown
    var minutes:Int!
    var seconds:Int!
    
    let userID = userDefault.object(forKey: USERID_STRING) as? Int
    var examID:Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AudioRecorderManager.shared.recorder?.prepareToRecord()
        
        circleTime.circleTimerWidth = 2
        circleTime.circleBackgroundColor = .clear
        circleTime.circleColor = .white
        circleTime.delegate = self
        recordingMess.isHidden = true
        nextBtn.isHidden = true
        
        examID = Exam?["id"] as? Int
        
        image_Question.isHidden = true
        tv_Data.isHidden = true
        
        if Exam?["question_1"] as? String == nil
        {
            lbl_Title.text = TITLEPHOTO
            image_Question.isHidden = false
            controlTextView.isHidden = true
            controlImageView.isHidden = false
            image_Question.contentMode = .scaleAspectFit
            image_Question.sd_setIndicatorStyle(.white)
            image_Question.sd_showActivityIndicatorView()
            image_Question.sd_setShowActivityIndicatorView(true)
            image_Question.sd_setImage(with: URL(string: Exam?["image_1"] as! String), placeholderImage: nil, options: [.continueInBackground]) { (iamge, error, type, url) in
                
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
            tv_Data.text = Exam?["question_1"] as? String
            circleTime.start(withSeconds: timeInitial)
            
        }
        
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
        
        if Exam?["image_1"] as? String != nil
        {
            let button = sender as! UIButton
            switch button.tag {
            case 1:
                let promt_1 = Exam?["promt1_1"] as? String
                self.alert_PromtQuestion(title: "", mess: promt_1)
                button.setTitle("", for: .normal)
                button.isEnabled = false
            case 2:
                let promt_2 = Exam?["promt1_2"] as? String
                self.alert_PromtQuestion(title: "", mess: promt_2)
                button.setTitle("", for: .normal)
                button.isEnabled = false
            case 3:
                let promt_3 = Exam?["promt1_3"] as? String
                self.alert_PromtQuestion(title: "", mess: promt_3)
                button.setTitle("", for: .normal)
                button.isEnabled = false
            default:
                return
            }
        }
    }
    
    
    @IBAction func nextBtnTap(_ sender: Any) {
        
        if isNext == false
        {
            self.stopRecord()
            self.viewbackground.frame.size.width = self.containerView.frame.size.width
            self.view.layoutIfNeeded()
            do
            {
                self.audio1_Data = try? Data(contentsOf: self.audioURL! as URL)
                print("audio1_Data",self.audio1_Data as Any)
                
            }
            
            isNext = true
        }
        
        
        
        if Connectivity.isConnectedToInternet
        {
            let part2VC = UIStoryboard(name: EXAMINEE_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "part2VC") as! Part2VC
            
            part2VC.Exam = self.Exam
            part2VC.examID = self.examID
            part2VC.audio1_Data = self.audio1_Data
            
            self.navigationController?.pushViewController(part2VC, animated: true)
        }
        else
        {
            self.displayAlertNetWorkNotAvailable()
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func onHandleRecordAudio()
    {
        self.StarRecording(userID: userID!, examID: examID, audio: 1) { (audioURLs:NSURL?) in
            self.audioURL = audioURLs
        }
        
        self.recordingMess.isHidden = false
        UIView.animate(withDuration: expectTime, delay: 0, options: [], animations: {
            self.viewbackground.frame.size.width = self.containerView.frame.size.width
            self.view.layoutIfNeeded()
        }) { (done) in
            if self.isNext == false
            {
                self.isNext = true
                self.recordingMess.text = "Time Out"
                self.stopRecord()
                do
                {
                    self.audio1_Data = try Data(contentsOf: self.audioURL! as URL)
                    print("audio1_Data",self.audio1_Data as Any)
                }
                catch
                {
                    
                }

            }
        }

    }
    
}

extension Part1VC: JWGCircleCounterDelegate
{
    func circleCounterTimeDidExpire(_ circleCounter: JWGCircleCounter!) {
        self.nextBtn.isHidden = false
        self.onHandleRecordAudio()
        
    }
}









