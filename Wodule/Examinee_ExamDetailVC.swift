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
    
    @IBOutlet weak var part1TitleLabel: UILabel!
    @IBOutlet weak var part2TitleLabel: UILabel!
    @IBOutlet weak var part3TitleLabel: UILabel!
    @IBOutlet weak var part4TitleLabel: UILabel!
    
    @IBOutlet weak var part1ScoreLabel: UILabelX!
    @IBOutlet weak var part2ScoreLabel: UILabelX!
    @IBOutlet weak var part3ScoreLabel: UILabelX!
    @IBOutlet weak var part4ScoreLabel: UILabelX!
    
    @IBOutlet weak var part1QuestionButton: UIButton!
    @IBOutlet weak var part2QuestionButton: UIButton!
    @IBOutlet weak var part3QuestionButton: UIButton!
    @IBOutlet weak var part4QuestionButton: UIButton!
    
    @IBOutlet weak var part1MainView: UIView!
    @IBOutlet weak var part2MainView: UIView!
    @IBOutlet weak var part3MainView: UIView!
    @IBOutlet weak var part4MainView: UIView!
    
    @IBOutlet weak var part1RunningView: UIView!
    @IBOutlet weak var part2RunningView: UIView!
    @IBOutlet weak var part3RunningView: UIView!
    @IBOutlet weak var part4RunningView: UIView!
    
    @IBOutlet weak var part1PlayButton: UIButton!
    @IBOutlet weak var part2PlayButton: UIButton!
    @IBOutlet weak var part3PlayButton: UIButton!
    @IBOutlet weak var part4PlayButton: UIButton!
    
    @IBOutlet weak var part1CountdownLabel: UILabel!
    @IBOutlet weak var part2CountdownLabel: UILabel!
    @IBOutlet weak var part3CountdownLabel: UILabel!
    @IBOutlet weak var part4CountdownLabel: UILabel!
    
    @IBOutlet weak var containerMainView: UIViewX!
    
    let VIEWPHOTO = "VIEW PHOTO"
    let VIEWTEXT = "VIEW TEXT"
    var backgroundView:UIView!
    @IBOutlet var questionTextView: UITextView!
    @IBOutlet var questionImage: UIImageView!
    
    var ExamDetail:NSDictionary!
    var part1Type:Int!
    var part2Type:Int!
    var part3Type:Int!
    var part4Type:Int!
    
    var isPlaying: Int!
    var time:Timer!
    var totalTime: TimeInterval!
    
    var currentAudioPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.onHandleInitData()
        
        part1CountdownLabel.isHidden = true
        part2CountdownLabel.isHidden = true
        part3CountdownLabel.isHidden = true
        part4CountdownLabel.isHidden = true

    }
    
    func onHandleInitData()
    {
        examIDLabel.text = ExamDetail["exam"] as? String
        
        if ExamDetail["score"] as? String == "pending"
        {
            part1ScoreLabel.text = "-"
            part2ScoreLabel.text = "-"
            part3ScoreLabel.text = "-"
            part4ScoreLabel.text = "-"
        }
        else
        {
            part1ScoreLabel.text = ExamDetail["score_1"] as? String
            part2ScoreLabel.text = ExamDetail["score_2"] as? String
            part3ScoreLabel.text = ExamDetail["score_3"] as? String
            part4ScoreLabel.text = ExamDetail["score_4"] as? String
        }
        
        if ((ExamDetail?["examQuestionaireOne"] as? String)?.hasPrefix("http://wodule.io/user/"))!
        {
            part1QuestionButton.setTitle(VIEWPHOTO, for: .normal)
            part1TitleLabel.text = TITLEPHOTO
            part1Type = 1
        }
        else
        {
            part1QuestionButton.setTitle(VIEWTEXT, for: .normal)
            part1TitleLabel.text = TITLESTRING
            part1Type = 0
            
        }
        if ((ExamDetail?["examQuestionaireTwo"] as? String)?.hasPrefix("http://wodule.io/user/"))!
        {
            part2QuestionButton.setTitle(VIEWPHOTO, for: .normal)
            part2TitleLabel.text = TITLEPHOTO
            part2Type = 1
        }
        else
        {
            part2QuestionButton.setTitle(VIEWTEXT, for: .normal)
            part2TitleLabel.text = TITLESTRING
            part2Type = 0
            
        }
        if ((ExamDetail?["examQuestionaireThree"] as? String)?.hasPrefix("http://wodule.io/user/"))!
        {
            part3QuestionButton.setTitle(VIEWPHOTO, for: .normal)
            part3TitleLabel.text = TITLEPHOTO
            part3Type = 1
        }
        else
        {
            part3QuestionButton.setTitle(VIEWTEXT, for: .normal)
            part3TitleLabel.text = TITLESTRING
            part3Type = 0
            
        }
        if ((ExamDetail?["examQuestionaireFour"] as? String)?.hasPrefix("http://wodule.io/user/"))!
        {
            part4QuestionButton.setTitle(VIEWPHOTO, for: .normal)
            part4TitleLabel.text = TITLEPHOTO
            part4Type = 1
        }
        else
        {
            part4QuestionButton.setTitle(VIEWTEXT, for: .normal)
            part4TitleLabel.text = TITLESTRING
            part4Type = 0
        }
    }
    
    @IBAction func onClickPart1Question(_ sender: Any) {
        self.onHandleDisplayView(type: part1Type, question: ExamDetail["examQuestionaireOne"] as! String)
    }
    
    @IBAction func onClickPart2Question(_ sender: Any) {
        self.onHandleDisplayView(type: part2Type, question: ExamDetail["examQuestionaireTwo"] as! String)
    }
    
    @IBAction func onClickPart3Question(_ sender: Any) {
        self.onHandleDisplayView(type: part3Type, question: ExamDetail["examQuestionaireThree"] as! String)
    }
    
    @IBAction func onClickPart4Question(_ sender: Any) {
        self.onHandleDisplayView(type: part4Type, question: ExamDetail["examQuestionaireFour"] as! String)
    }
    
    @IBAction func onClickPart1Audio(_ sender: Any) {
        isPlaying = 1
        currentAudioPlayer = AVAudioPlayer()
        self.onHandlePlayAudio(link: ExamDetail["audio_1"] as! String, button: part1PlayButton, runningView: part1RunningView, mainView: part1MainView, label: part1CountdownLabel)
        self.onHandleDisableButton(sub1: part2PlayButton, sub2: part3PlayButton, sub3: part4PlayButton, isStatus: false)
    }
    
    @IBAction func onClickPart2Audio(_ sender: Any) {
        
        isPlaying = 2
        currentAudioPlayer = AVAudioPlayer()

        self.onHandlePlayAudio(link: ExamDetail["audio_2"] as! String, button: part2PlayButton, runningView: part2RunningView, mainView: part2MainView, label: part2CountdownLabel)
        self.onHandleDisableButton(sub1: part1PlayButton, sub2: part3PlayButton, sub3: part4PlayButton, isStatus: false)
        
    }
    
    @IBAction func onClickPart3Audio(_ sender: Any) {
        isPlaying = 3
        currentAudioPlayer = AVAudioPlayer()

        self.onHandlePlayAudio(link: ExamDetail["audio_3"] as! String, button: part3PlayButton, runningView: part3RunningView, mainView: part3MainView, label: part3CountdownLabel)
        self.onHandleDisableButton(sub1: part1PlayButton, sub2: part2PlayButton, sub3: part4PlayButton, isStatus: false)

    }
    
    @IBAction func onClickPart4Audio(_ sender: Any) {
        isPlaying = 4
        currentAudioPlayer = AVAudioPlayer()

        self.onHandlePlayAudio(link: ExamDetail["audio_4"] as! String, button: part4PlayButton, runningView: part4RunningView, mainView: part4MainView, label: part4CountdownLabel)
        self.onHandleDisableButton(sub1: part2PlayButton, sub2: part3PlayButton, sub3: part1PlayButton, isStatus: false)

    }
    
    @IBAction func onClickBack(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func setupViewData(subView: UIView, height: CGFloat, width: CGFloat, x: CGFloat)
    {
        backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        backgroundView.backgroundColor = UIColor.gray
        backgroundView.alpha = 0
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleCloseView))
        tapGesture.numberOfTapsRequired = 1
        backgroundView.addGestureRecognizer(tapGesture)
        
        view.addSubview(backgroundView)
        view.addSubview(subView)
        subView.layer.cornerRadius = 10
        
        let heightView:CGFloat = height
        subView.frame = CGRect(x: x, y: (view.frame.size.height - heightView) / 2 , width: width, height: heightView)
        subView.alpha = 0
    }
    
    func handleCloseView()
    {
        UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
            self.backgroundView.alpha = 0
            self.questionImage.alpha = 0
            self.questionTextView.alpha = 0
        }, completion: { (true) in
            self.perform(#selector(self.removeView), with: self, afterDelay: 0)
            
        })
    }
    
    func removeView()
    {
        self.questionImage.removeFromSuperview()
        self.questionTextView.removeFromSuperview()
        self.backgroundView.removeFromSuperview()

    }
    
    func onHandleDisplayView(type:Int, question: String)
    {
        if type == 1
        {
            onHandleViewData(subView: questionImage, height: view.frame.height / 2, width: self.view.frame.width, xFrame: 0)
            questionImage.sd_setImage(with: URL(string: question), placeholderImage: nil, options: [], completed: nil)
        }
        else
        {
            onHandleViewData(subView: questionTextView, height: view.frame.height / 3, width: self.view.frame.width, xFrame: 0)
            questionTextView.text =  question
            questionTextView.textContainerInset = UIEdgeInsetsMake(10, 8, 5, 8)
        }
    }

    func onHandleViewData(subView: UIView, height: CGFloat,width:CGFloat, xFrame:CGFloat)
    {
        
        setupViewData(subView: subView, height: height, width: width, x: xFrame)
        createAnimatePopup(from: subView, with: backgroundView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if currentAudioPlayer != nil
        {
            self.currentAudioPlayer?.stop()
            self.currentAudioPlayer = nil
        }
        
    }
    
    
    func onHandlePlayAudio(link: String, button: UIButton, runningView: UIView, mainView: UIView, label: UILabel)
    {
        
        runningView.frame.size.width = 0
        loadingShow()
        let urlPath = URL(string: link)
        DispatchQueue.global(qos: .background).async {
            do
            {
                let data = try Data(contentsOf: urlPath!)
                do {
                    self.currentAudioPlayer = try AVAudioPlayer(data: data)
                    print("DATA", data)
                    DispatchQueue.main.async(execute: {
                        button.isHidden = true
                        label.isHidden = false
                        self.currentAudioPlayer?.play()
                        self.currentAudioPlayer?.delegate = self
                        self.loadingHide()
                        print("TOTAL TIME:",self.currentAudioPlayer?.duration as Any)
                        
                        UIView.animate(withDuration: (self.currentAudioPlayer?.duration)!, animations: {
                            runningView.frame.size.width = mainView.frame.width
                            self.view.layoutIfNeeded()
                        })
                    })
                }
                catch
                {
                    print("cannot play")
                    self.loadingHide()
                }
            }
            catch
            {
                print("Cannot get data")
                self.loadingHide()
            }
        }

    }
    
    func onHandleUpdateTime()
    {
        
        let minute = Int((self.currentAudioPlayer?.duration)!) / 60
        let second = Int((self.currentAudioPlayer?.duration)!) % 60
        
        switch isPlaying {
        case 1:
            self.part1CountdownLabel.isHidden = false
            if minute < 10 && second < 10
            {
                self.part1CountdownLabel.text  = "0\(minute):0\(second)"

            }
            else if minute < 10
            {
                self.part1CountdownLabel.text  = "0\(minute):\(second)"

            }
            else if second < 10
            {
                self.part1CountdownLabel.text  = "\(minute):0\(second)"

            }
            else
            {
                self.part1CountdownLabel.text  = "\(minute):\(second)"
            }
        case 2:
            self.part2CountdownLabel.isHidden = false

            if minute < 10 && second < 10
            {
                self.part2CountdownLabel.text  = "0\(minute):0\(second)"
                
            }
            else if minute < 10
            {
                self.part2CountdownLabel.text  = "0\(minute):\(second)"
                
            }
            else if second < 10
            {
                self.part2CountdownLabel.text  = "\(minute):0\(second)"
                
            }
            else
            {
                self.part2CountdownLabel.text  = "\(minute):\(second)"
            }

        case 3:
            self.part3CountdownLabel.isHidden = false

            if minute < 10 && second < 10
            {
                self.part3CountdownLabel.text  = "0\(minute):0\(second)"
                
            }
            else if minute < 10
            {
                self.part3CountdownLabel.text  = "0\(minute):\(second)"
                
            }
            else if second < 10
            {
                self.part3CountdownLabel.text  = "\(minute):0\(second)"
                
            }
            else
            {
                self.part3CountdownLabel.text  = "\(minute):\(second)"
            }

        default:
            self.part4CountdownLabel.isHidden = false

            if minute < 10 && second < 10
            {
                self.part4CountdownLabel.text  = "0\(minute):0\(second)"
                
            }
            else if minute < 10
            {
                self.part4CountdownLabel.text  = "0\(minute):\(second)"
                
            }
            else if second < 10
            {
                self.part4CountdownLabel.text  = "\(minute):0\(second)"
                
            }
            else
            {
                self.part4CountdownLabel.text  = "\(minute):\(second)"
            }

        }
        
        self.totalTime = self.totalTime - 1

    }
    
    func onHandleDisableButton(sub1: UIButton, sub2:UIButton, sub3: UIButton, isStatus: Bool)
    {
        sub1.isUserInteractionEnabled = isStatus
        sub2.isUserInteractionEnabled = isStatus
        sub3.isUserInteractionEnabled = isStatus
    }
    
}

extension Examinee_ExamDetailVC: AVAudioPlayerDelegate
{
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
        switch isPlaying {
        case 1:
            print("FINISH 1")
            self.currentAudioPlayer?.stop()
            self.part1PlayButton.isHidden = false
            self.currentAudioPlayer = nil
            self.onHandleDisableButton(sub1: part2PlayButton, sub2: part3PlayButton, sub3: part4PlayButton, isStatus: true)
            self.part1CountdownLabel.isHidden = true
        case 2:
            print("FINISH 2")
            self.currentAudioPlayer?.stop()
            self.part2PlayButton.isHidden = false
            self.currentAudioPlayer = nil
            self.onHandleDisableButton(sub1: part1PlayButton, sub2: part3PlayButton, sub3: part4PlayButton, isStatus: true)
            self.part2CountdownLabel.isHidden = true

        case 3:
            print("FINISH 3")
            self.currentAudioPlayer?.stop()
            self.part3PlayButton.isHidden = false
            self.currentAudioPlayer = nil
            self.onHandleDisableButton(sub1: part1PlayButton, sub2: part2PlayButton, sub3: part4PlayButton, isStatus: true)
            self.part3CountdownLabel.isHidden = true

        default:
            print("FINISH 4")
            self.currentAudioPlayer?.stop()
            self.part4PlayButton.isHidden = false
            self.currentAudioPlayer = nil
            self.onHandleDisableButton(sub1: part1PlayButton, sub2: part2PlayButton, sub3: part3PlayButton, isStatus: true)
            self.part4CountdownLabel.isHidden = true

        }
        
    }
}








