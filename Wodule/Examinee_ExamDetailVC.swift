//
//  Examinee_ExamDetailVC.swift
//  Wodule
//
//  Created by QTS Coder on 10/26/17.
//  Copyright © 2017 QTS. All rights reserved.
//

import UIKit
import AVFoundation

class Examinee_ExamDetailVC: UIViewController {

    @IBOutlet weak var examIDLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var examCategoryLabel: UILabel!
    @IBOutlet weak var examDetailLabel: UILabel!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var contentImage: UIImageView!
    @IBOutlet weak var play_pauseButton: UIButton!
    @IBOutlet weak var underLabel: UILabelX!
    @IBOutlet weak var hContentTextView: NSLayoutConstraint!
    
    var ExamDetail: AssesmentHistory?
    var currentPlayer: AVAudioPlayer?
    var isTapped:Bool!
    var isPlaying:Bool!
    var data: Data?

    
    override func viewDidLoad() {
        super.viewDidLoad()

//        contentImage.isHidden = true
//        contentTextView.isHidden = true
//        underLabel.isHidden = true
//        
//        self.onHandleAssignData()
//        currentPlayer = AVAudioPlayer()
//        
//        let url = URL(string: (ExamDetail?.audio)!)
//        play_pauseButton.isHidden = true
//        self.loadingShow()
//        DispatchQueue.global(qos: .background).async {
//            do
//            {
//                let data = try Data(contentsOf: url!)
//                do {
//                    self.currentPlayer = try AVAudioPlayer(data: data)
//                    DispatchQueue.main.async(execute: {
//                        self.currentPlayer?.play()
//                        self.currentPlayer?.pause()
//                        self.currentPlayer?.delegate = self
//                        self.loadingHide()
//                        self.play_pauseButton.isHidden = false
//                        print("TOTAL TIME:",self.currentPlayer?.duration as Any)
//                    })
//                }
//                catch
//                {
//                    print("cannot play")
//                }
//            }
//            catch
//            {
//                print("Cannot get data")
//            }
//        }
//        
//        isPlaying = false
//        isTapped = false
        
        
        // Do any additional setup after loading the view.
    }
    
//    func onHandleAssignData()
//    {
//        examIDLabel.text = ExamDetail?.exam
//        dateLabel.text = ExamDetail?.creationDate
//        
//        if ExamDetail!.score == 0
//        {
//            commentLabel.text = ""
//            scoreLabel.text = "-"
//        }
//        else
//        {
//            commentLabel.text = ExamDetail?.comment
//            scoreLabel.text = "\(ExamDetail!.score)"
//        }
//        
//        
//        examCategoryLabel.text = ExamDetail?.examCategory
//        examDetailLabel.text = ExamDetail?.examDetails
//        
//        if (ExamDetail?.examQuestionaire.hasPrefix("http://wodule.io/user/"))!
//        {
//            
//            contentImage.sd_setImage(with: URL(string: ExamDetail!.examQuestionaire), placeholderImage: nil, options: .continueInBackground, completed: nil)
//            contentImage.isHidden = false
//            contentImage.contentMode = .scaleAspectFit
//            hContentTextView.constant = self.view.frame.width * (2/3)
//            
//        }
//        else
//        {
//            contentTextView.text = ExamDetail?.examQuestionaire
//            contentTextView.isHidden = false
//            underLabel.isHidden = false
//            
//        }
//    }
//    
//    func pause()
//    {
//        currentPlayer?.pause()
//        print("PAUSED at:", (currentPlayer?.currentTime)!)
//        isPlaying = false
//    }
//    
//    func resume()
//    {
//        currentPlayer?.play()
//        isPlaying = true
//        print("PLAY AGAIN at:", (currentPlayer?.currentTime)!)
//        
//    }
//    
//    func stop()
//    {
//        currentPlayer?.stop()
//        isPlaying = false
//    }
//
//    @IBAction func onClickPlay(_ sender: Any) {
//        
//        let button = sender as! UIButton
//        play_pauseAudio(button: button, isPlay: isTapped)
//        
//        if isPlaying
//        {
//            pause()
//            
//        }
//        else
//        {
//            resume()
//            
//        }
//        
//        isTapped = !isTapped
//        print(isPlaying)
//    }
//    @IBAction func onClickBack(_ sender: Any) {
//        self.navigationController?.popViewController(animated: true)
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        self.stop()
//    }
   

}

//extension Examinee_ExamDetailVC: AVAudioPlayerDelegate
//{
//    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
//        print("DID PLAYED")
//        self.stop()
//        self.play_pauseButton.setImage(#imageLiteral(resourceName: "btn_play"), for: .normal)
//        self.isTapped = false
//    }
//}

