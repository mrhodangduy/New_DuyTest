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
    
    var Exam:NSDictionary?
    var audio1_Data: Data?
    
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
            decreaseBtn.isHidden = true
            increaseBtn.isHidden = true
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
            tv_Data.isHidden = false
            tv_Data.text = Exam?["question_1"] as? String
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
        let part2VC = UIStoryboard(name: EXAMINEE_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "part2VC") as! Part2VC
        
        part2VC.Exam = self.Exam
        part2VC.examID = self.examID
        part2VC.audio1_Data = self.audio1_Data
        
        self.navigationController?.pushViewController(part2VC, animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
}

extension Part1VC: JWGCircleCounterDelegate
{
    func circleCounterTimeDidExpire(_ circleCounter: JWGCircleCounter!) {
        
        var audioURL:NSURL?
        self.StarRecording(userID: userID!, examID: examID, audio: 1) { (audioURLs:NSURL?) in
            audioURL = audioURLs
        }
        
        self.recordingMess.isHidden = false
        UIView.animate(withDuration: expectTime, delay: 0, options: [], animations: {
            self.viewbackground.frame.size.width = self.containerView.frame.size.width
            self.view.layoutIfNeeded()
        }) { (done) in
            self.nextBtn.isHidden = false
            self.recordingMess.text = "Time Out"
            self.stopRecord()
            do
            {
                self.audio1_Data = try Data(contentsOf: audioURL! as URL)
                print("audio1_Data",self.audio1_Data)
            }
        
            catch
            {
                
            }
        }
        
    }
}









