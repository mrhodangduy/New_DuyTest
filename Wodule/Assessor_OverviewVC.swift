//
//  Assessor_OverviewVC.swift
//  Wodule
//
//  Created by QTS Coder on 10/4/17.
//  Copyright © 2017 QTS. All rights reserved.
//

import UIKit
import SDWebImage
import AVFoundation

class Assessor_OverviewVC: UIViewController {
    
    var isPlaying: Int!
    
    @IBOutlet var dataTableView: UITableView!
    @IBOutlet var contentTextView: UITextView!
    @IBOutlet var contentImageView: UIImageView!
    var backgroundView:UIView!
    var currentIndex:Int!
    
    @IBOutlet weak var part1_ViewData: UIButton!
    @IBOutlet weak var part2_ViewData: UIButton!
    @IBOutlet weak var part3_ViewData: UIButton!
    @IBOutlet weak var part4_ViewData: UIButton!
    @IBOutlet weak var part1TitleLabel: UILabel!
    @IBOutlet weak var part2TitleLabel: UILabel!
    @IBOutlet weak var part3TitleLabel: UILabel!
    @IBOutlet weak var part4TitleLabel: UILabel!
    @IBOutlet weak var examIDLabel: UILabel!
    @IBOutlet weak var mainContainerView: UIView!
    @IBOutlet weak var part3ContainerView: UIView!
    @IBOutlet weak var part4ContainerView: UIView!
    
    @IBOutlet weak var part1PlayingLabel: UILabel!
    @IBOutlet weak var part2PlayingLabel: UILabel!
    @IBOutlet weak var part3PlayingLabel: UILabel!
    @IBOutlet weak var part4PlayingLabel: UILabel!
    @IBOutlet weak var mainScrollView: UIScrollView!
    
    var numberOfQuestion:Int!
    
    var data1: Data?
    var data2: Data?
    var data3: Data?
    var data4: Data?
    
    var part1Type:Int!
    var part2Type:Int!
    var part3Type:Int!
    var part4Type:Int!
    
    let VIEWPHOTO = "VIEW PHOTO"
    let VIEWTEXT = "VIEW TEXT"
    
    var widthViewScore: CGFloat!
    var widthViewPhoto: CGFloat!
    var xFrame: CGFloat!
    var currentAudioPlayer: AVAudioPlayer?
    
    
    var Exam: NSDictionary?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        widthViewScore = view.frame.size.width * (4/6)
        widthViewPhoto = view.frame.size.width
        xFrame = view.frame.size.width * (1/6)
        
        onHandleInitView()
        
        dataTableView.dataSource = self
        dataTableView.delegate = self
        
        part1PlayingLabel.isHidden = true
        part2PlayingLabel.isHidden = true
        part3PlayingLabel.isHidden = true
        part4PlayingLabel.isHidden = true
        
        
    }
    
    func onHandleInitView()
    {
        examIDLabel.text = Exam?["exam"] as? String
        
        if (Exam?["examQuestionaireThree"] as? String) == nil
        {
            part3ContainerView.isHidden = true
            part4ContainerView.isHidden = true
            mainScrollView.isScrollEnabled = false
            
        }
        
        if ((Exam?["examQuestionaireOne"] as? String)?.hasPrefix("http://wodule.io/user/")) == true
        {
            part1_ViewData.setTitle(VIEWPHOTO, for: .normal)
            part1TitleLabel.text = TITLEPHOTO
            part1Type = 1
        }
        else
        {
            part1_ViewData.setTitle(VIEWTEXT, for: .normal)
            part1TitleLabel.text = TITLESTRING
            part1Type = 0
            
        }
        if ((Exam?["examQuestionaireTwo"] as? String)?.hasPrefix("http://wodule.io/user/")) == true
        {
            part2_ViewData.setTitle(VIEWPHOTO, for: .normal)
            part2TitleLabel.text = TITLEPHOTO
            part2Type = 1
        }
        else
        {
            part2_ViewData.setTitle(VIEWTEXT, for: .normal)
            part2TitleLabel.text = TITLESTRING
            part2Type = 0
            
        }
        if ((Exam?["examQuestionaireThree"] as? String)?.hasPrefix("http://wodule.io/user/")) == true
        {
            part3_ViewData.setTitle(VIEWPHOTO, for: .normal)
            part3TitleLabel.text = TITLEPHOTO
            part3Type = 1
        }
        else
        {
            part3_ViewData.setTitle(VIEWTEXT, for: .normal)
            part3TitleLabel.text = TITLESTRING
            part3Type = 0
            
        }
        if ((Exam?["examQuestionaireFour"] as? String)?.hasPrefix("http://wodule.io/user/")) == true
        {
            part4_ViewData.setTitle(VIEWPHOTO, for: .normal)
            part4TitleLabel.text = TITLEPHOTO
            part4Type = 1
        }
        else
        {
            part4_ViewData.setTitle(VIEWTEXT, for: .normal)
            part4TitleLabel.text = TITLESTRING
            part4Type = 0
        }
        
        
        let score_Part1 = userDefault.object(forKey: SCORE_PART1) as? Int
        let score_Part2 = userDefault.object(forKey: SCORE_PART2) as? Int
        let score_Part3 = userDefault.object(forKey: SCORE_PART3) as? Int
        let score_Part4 = userDefault.object(forKey: SCORE_PART4) as? Int
        
        if score_Part1 != nil
        {
            part1ScoreLabel.text = "\(score_Part1!)"
        }
        if score_Part2 != nil
        {
            part2ScoreLabel.text = "\(score_Part2!)"
        }
        if score_Part3 != nil
        {
            part3ScoreLabel.text = "\(score_Part3!)"
        }
        if score_Part4 != nil
        {
            part4ScoreLabel.text = "\(score_Part4!)"
        }
        
        if numberOfQuestion == 2
        {
            part3ContainerView.isHidden = true
            part4ContainerView.isHidden = true
        }
        if numberOfQuestion  == 3
        {
            part4ContainerView.isHidden = true
        }
    }
    
    func onHandleDisplayView(type:Int, question: String)
    {
        if type == 1
        {
            onHandleViewData(subView: contentImageView, height: view.frame.height / 2, width: widthViewPhoto, xFrame: 0)
            contentImageView.sd_setImage(with: URL(string: question), placeholderImage: nil, options: [], completed: nil)
        }
        else
        {
            onHandleViewData(subView: contentTextView, height: view.frame.height * (2/3), width: self.view.frame.width, xFrame: 0)
            contentTextView.text =  question
            contentTextView.textContainerInset = UIEdgeInsetsMake(20, 20, 10, 10)
            
        }
    }
    
    //Part1
    @IBOutlet weak var background1: UIView!
    @IBOutlet weak var runningView1: UIView!
    @IBOutlet weak var part1ScoreLabel: UILabelX!
    @IBOutlet weak var part1PlayButton: UIButton!
    
    @IBAction func part1_playAudioTap(_ sender: Any) {
        currentAudioPlayer = AVAudioPlayer()

        isPlaying = 1
        self.onHandlePlayAudio(data: data1!, button: part1PlayButton, runningView: runningView1, mainView: background1, label: part1PlayingLabel)
        self.onHandleDisableButton(sub1: part2PlayButton, sub2: part3PlayButton, sub3: part4PlayButton, isStatus: false)
    }
    
    @IBAction func part1_viewTextTap(_ sender: Any) {
        
        onHandleDisplayView(type: part1Type, question: (Exam?["examQuestionaireOne"] as? String)!)
        
    }
    
    @IBAction func part1_ScoreTap(_ sender: Any) {
        
        currentIndex = 1
        configView()
    }
    
    
    //Part2
    @IBOutlet weak var background2: UIView!
    @IBOutlet weak var runningView2: UIView!
    @IBOutlet weak var part2ScoreLabel: UILabelX!
    @IBOutlet weak var part2PlayButton: UIButton!
    
    @IBAction func part2_PlayAudioTap(_ sender: Any) {
        isPlaying = 2
        currentAudioPlayer = AVAudioPlayer()

        self.onHandlePlayAudio(data: data2!, button: part2PlayButton, runningView: runningView2, mainView: background2, label: part2PlayingLabel)
        self.onHandleDisableButton(sub1: part1PlayButton, sub2: part3PlayButton, sub3: part4PlayButton, isStatus: false)
    }
    @IBAction func part2_ViewPhotoTap(_ sender: Any) {
        
        onHandleDisplayView(type: part2Type, question: (Exam?["examQuestionaireTwo"] as? String)!)
        
    }
    @IBAction func part2_ScoreTap(_ sender: Any) {
        
        currentIndex = 2
        configView()
    }
    
    //Part3
    @IBOutlet weak var background3: UIView!
    @IBOutlet weak var runningView3: UIView!
    @IBOutlet weak var part3ScoreLabel: UILabelX!
    @IBOutlet weak var part3PlayButton: UIButton!
    
    @IBAction func part3_PlayAudioTap(_ sender: Any) {
        isPlaying = 3
        currentAudioPlayer = AVAudioPlayer()

        self.onHandlePlayAudio(data: data3!, button: part3PlayButton, runningView: runningView3, mainView: background3, label: part3PlayingLabel)
        self.onHandleDisableButton(sub1: part1PlayButton, sub2: part2PlayButton, sub3: part4PlayButton, isStatus: false)
    }
    
    @IBAction func part3_ViewData(_ sender: Any) {
        
        onHandleDisplayView(type: part3Type, question: (Exam?["examQuestionaireThree"] as? String)!)
        
    }
    
    
    @IBAction func part3_ScoreTap(_ sender: Any) {
        
        currentIndex = 3
        configView()
        
    }
    
    //Part4
    @IBOutlet weak var background4: UIView!
    @IBOutlet weak var runningView4: UIView!
    @IBOutlet weak var part4ScoreLabel: UILabelX!
    @IBOutlet weak var part4PlayButton: UIButton!
    
    @IBAction func part4_PlayAudioTap(_ sender: Any) {
        
        isPlaying = 4
        currentAudioPlayer = AVAudioPlayer()

        self.onHandlePlayAudio(data: data4!, button: part4PlayButton, runningView: runningView4, mainView: background4, label: part4PlayingLabel)
        self.onHandleDisableButton(sub1: part2PlayButton, sub2: part3PlayButton, sub3: part1PlayButton, isStatus: false)
        
    }
    @IBAction func part4_ScoreTap(_ sender: Any) {
        
        currentIndex = 4
        configView()
    }
    
    @IBAction func part4_ViewData(_ sender: Any) {
        
        onHandleDisplayView(type: part4Type, question: (Exam?["examQuestionaireFour"] as? String)!)
        
    }
    
    @IBAction func submitTap(_ sender: Any) {
        
        if Connectivity.isConnectedToInternet
        {
            if self.currentAudioPlayer != nil
            {
                self.currentAudioPlayer?.stop()
                self.currentAudioPlayer = nil
            }
            
            let score_Part1 = userDefault.object(forKey: SCORE_PART1) as? Int
            let score_Part2 = userDefault.object(forKey: SCORE_PART2) as? Int
            let score_Part3 = userDefault.object(forKey: SCORE_PART3) as? Int
            let score_Part4 = userDefault.object(forKey: SCORE_PART4) as? Int
            let comment_Part1 = userDefault.object(forKey: COMMENT_PART1) as? String
            let comment_Part2 = userDefault.object(forKey: COMMENT_PART2) as? String
            let comment_Part3 = userDefault.object(forKey: COMMENT_PART3) as? String
            let comment_Part4 = userDefault.object(forKey: COMMENT_PART4) as? String
            
            if score_Part1 == nil
            {
                self.alertMissingText(mess: "Part 1 must be assigned a score.", textField: nil)
            }
            else if score_Part2 == nil
            {
                self.alertMissingText(mess: "Part 2 must be assigned a score.", textField: nil)
            }
            else if score_Part3 == nil && numberOfQuestion > 2
            {
                self.alertMissingText(mess: "Part 3 must be assigned a score.", textField: nil)
            }
            else if score_Part4 == nil && numberOfQuestion > 3
            {
                self.alertMissingText(mess: "Part 4 must be assigned a score.", textField: nil)
            }
            else
            {
                self.loadingShow()
                let token = userDefault.object(forKey: TOKEN_STRING) as? String
                let identifier = userDefault.integer(forKey: IDENTIFIER_KEY)
                
                ExamRecord.postGrade(withToken: token!, identifier: identifier, grade1: score_Part1!, comment1: comment_Part1!, grade2: score_Part2!, comment2: comment_Part2!, grade3: score_Part3, comment3: comment_Part3, grade4: score_Part4, comment4: comment_Part4, completion: { (status:Bool?, code:Int?, result:NSDictionary?) in
                    print(status as Any, code as Any , result as Any)
                    
                    if status!
                    {
                        print("grade susscessful")
                        self.loadingHide()
                        let accountingVC = UIStoryboard(name: ASSESSOR_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "accountingVC") as! Assessor_AccountingVC
                        self.navigationController?.pushViewController(accountingVC, animated: true)
                        self.removeScoreObject()
                    }
                        
                    else if code == 409
                    {
                        self.loadingHide()
                        self.alertMissingText(mess: "The particular audio has already a grade.", textField: nil)
                    }
                    else
                    {
                        self.loadingHide()
                        self.alertMissingText(mess: "Failed to grade exam.", textField: nil)
                    }
                })
                
            }
        }
        else
        {
            self.displayAlertNetWorkNotAvailable()
        }
                
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
            self.dataTableView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
            self.contentTextView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
            self.contentImageView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)

            self.backgroundView.alpha = 0
            self.dataTableView.alpha = 0
            self.contentTextView.alpha = 0
            self.contentImageView.alpha = 0
        }, completion: { (true) in
            self.perform(#selector(self.removeView), with: self, afterDelay: 0)
            
        })
    }
    
    func removeView()
    {
        self.backgroundView.removeFromSuperview()
        self.dataTableView.removeFromSuperview()
        self.contentTextView.removeFromSuperview()
        self.contentImageView.removeFromSuperview()
        self.dataTableView.transform = .identity
        self.contentTextView.transform = .identity
        self.contentImageView.transform = .identity

    }
    
    func configView()
    {
        let height:CGFloat = self.view.frame.height * (2/3)
        setupViewData(subView: dataTableView, height: height, width: widthViewScore, x: xFrame)
        createAnimatePopup(from: dataTableView, with: backgroundView)
        dataTableView.reloadData()
    }
    
    func onHandleViewData(subView: UIView, height: CGFloat,width:CGFloat, xFrame:CGFloat)
    {
        
        setupViewData(subView: subView, height: height, width: width, x: xFrame)
        createAnimatePopup(from: subView, with: backgroundView)
    }
    
    func onHandlePlayAudio(data: Data, button: UIButton, runningView: UIView, mainView: UIView,label: UILabel)
    {
        runningView.frame.size.width = 0
        loadingShow()
        DispatchQueue.global(qos: .background).async {
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
        
    }
    
    func onHandleDisableButton(sub1: UIButton, sub2:UIButton, sub3: UIButton, isStatus: Bool)
    {
        sub1.isUserInteractionEnabled = isStatus
        sub2.isUserInteractionEnabled = isStatus
        sub3.isUserInteractionEnabled = isStatus
    }
    
    func removeScoreObject()
    {
        userDefault.removeObject(forKey: SCORE_PART1)
        userDefault.removeObject(forKey: SCORE_PART2)
        userDefault.removeObject(forKey: SCORE_PART3)
        userDefault.removeObject(forKey: SCORE_PART4)
        userDefault.removeObject(forKey: COMMENT_PART1)
        userDefault.removeObject(forKey: COMMENT_PART2)
        userDefault.removeObject(forKey: COMMENT_PART3)
        userDefault.removeObject(forKey: COMMENT_PART4)
        userDefault.removeObject(forKey: IDENTIFIER_KEY)
        userDefault.synchronize()
    }
    
    
}

extension Assessor_OverviewVC:UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! Assessor_OverViewCell
        
        cell.lbl_Point.text = "\(indexPath.row + 1)"
        return cell
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 35
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch currentIndex {
        case 1:
            part1ScoreLabel.text = "\(indexPath.row + 1)"
            userDefault.set(indexPath.row + 1, forKey: SCORE_PART1)
        case 2:
            part2ScoreLabel.text = "\(indexPath.row + 1)"
            userDefault.set(indexPath.row + 1, forKey: SCORE_PART2)
        case 3:
            part3ScoreLabel.text = "\(indexPath.row + 1)"
            userDefault.set(indexPath.row + 1, forKey: SCORE_PART3)
        case 4:
            part4ScoreLabel.text = "\(indexPath.row + 1)"
            userDefault.set(indexPath.row + 1, forKey: SCORE_PART4)
        default:
            return
        }
        userDefault.synchronize()
        handleCloseView()
    }
}

extension Assessor_OverviewVC: AVAudioPlayerDelegate
{
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        switch isPlaying {
        case 1:
            print("FINISH 1")
            self.currentAudioPlayer?.stop()
            self.part1PlayButton.isHidden = false
            self.currentAudioPlayer = nil
            self.onHandleDisableButton(sub1: part2PlayButton, sub2: part3PlayButton, sub3: part4PlayButton, isStatus: true)
            self.part1PlayingLabel.isHidden = true
        case 2:
            print("FINISH 2")
            self.currentAudioPlayer?.stop()
            self.part2PlayButton.isHidden = false
            self.currentAudioPlayer = nil
            self.onHandleDisableButton(sub1: part1PlayButton, sub2: part3PlayButton, sub3: part4PlayButton, isStatus: true)
            self.part2PlayingLabel.isHidden = true
            
        case 3:
            print("FINISH 3")
            self.currentAudioPlayer?.stop()
            self.part3PlayButton.isHidden = false
            self.currentAudioPlayer = nil
            self.onHandleDisableButton(sub1: part1PlayButton, sub2: part2PlayButton, sub3: part4PlayButton, isStatus: true)
            self.part3PlayingLabel.isHidden = true
            
        default:
            print("FINISH 4")
            self.currentAudioPlayer?.stop()
            self.part4PlayButton.isHidden = false
            self.currentAudioPlayer = nil
            self.onHandleDisableButton(sub1: part1PlayButton, sub2: part2PlayButton, sub3: part3PlayButton, isStatus: true)
            self.part4PlayingLabel.isHidden = true
            
        }
        
    }
}



