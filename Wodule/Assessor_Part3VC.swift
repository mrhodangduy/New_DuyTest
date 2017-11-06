//
//  Assessor_Part3VC.swift
//  Wodule
//
//  Created by QTS Coder on 10/4/17.
//  Copyright © 2017 QTS. All rights reserved.
//

import UIKit
import AVFoundation

class Assessor_Part3VC: UIViewController {

    @IBOutlet weak var containerViewHeight: NSLayoutConstraint!
    @IBOutlet var dataTableView: UITableView!
    var backgroundView:UIView!

    @IBOutlet weak var titleQuestion: UILabel!
    @IBOutlet weak var controlFontSizeView: UIView!
    @IBOutlet weak var controlImageView: UIView!
    @IBOutlet weak var tv_Content: UITextView!
    @IBOutlet weak var img_Question: UIImageViewX!
    @IBOutlet weak var tv_Comment: RoundTextView!
    @IBOutlet weak var scoreBtn: UIButton!
    @IBOutlet weak var play_pauseBtn: UIButton!
    var score = 0
    var Exam:NSDictionary?
    
    var isExpanding:Bool!
    var originalHeight:CGFloat!
    var isPlaying:Bool!
    var isTapped:Bool!

    var currentPlayer: AVAudioPlayer?
    
    var data1: Data?
    var data2: Data?
    var data3: Data?
    
    func onHandleSetupAudio()
    {
        currentPlayer = AVAudioPlayer()
        let url = URL(string: Exam?["audio_3"] as! String)
        play_pauseBtn.isHidden = true
        self.loadingShow()
        DispatchQueue.global(qos: .background).async {
            do
            {
                self.data3 = try Data(contentsOf: url!)
                do {
                    self.currentPlayer = try AVAudioPlayer(data: self.data3!)
                    DispatchQueue.main.async(execute: {
                        self.currentPlayer?.play()
                        self.currentPlayer?.pause()
                        self.currentPlayer?.delegate = self
                        self.loadingHide()
                        self.play_pauseBtn.isHidden = false
                        print("TOTAL TIME:",self.currentPlayer?.duration as Any)
                    })
                }
                catch
                {
                    print("cannot play")
                }
            }
            catch
            {
                print("Cannot get data")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        onHandleSetupAudio()

        originalHeight = UIScreen.main.bounds.size.height * COMMENTVIEW_HEIGHT
        containerViewHeight.constant = 10
        isExpanding = false
        isPlaying = false
        isTapped = false
        
        dataTableView.dataSource = self
        dataTableView.delegate = self

        
        if ((Exam?["examQuestionaireThree"] as? String)?.hasPrefix("http://wodule.io/user/"))!
        {
            img_Question.isHidden = false
            titleQuestion.text = TITLEPHOTO
            img_Question.sd_setImage(with: URL(string: Exam?["examQuestionaireThree"] as! String), placeholderImage: nil, options: [], completed: nil)
            controlFontSizeView.isHidden = true
            controlImageView.isHidden = false
            tv_Content.isHidden = true
        }
        else
        {
            img_Question.isHidden = true
            titleQuestion.text = TITLESTRING
            controlFontSizeView.isHidden = false
            controlImageView.isHidden = true
            tv_Content.isHidden = false
            tv_Content.textContainerInset = UIEdgeInsetsMake(20, 20, 10, 10)
            tv_Content.text = Exam?["examQuestionaireThree"] as! String
        }
        
    }
    
    @IBAction func onClickPromtQuestion(_ sender: Any) {
        if Exam?["image_3"] as? String != nil
        {
            let promt_1 = Exam?["promt3_1"] as? String
            let promt_2 = Exam?["promt3_2"] as? String
            let promt_3 = Exam?["promt3_3"] as? String
            self.alert_PromtQuestion(title: "Question", mess: promt_1! + promt_2! + promt_3! )
        }
    }
    
    
    @IBAction func onClickIncrease(_ sender: Any) {
        tv_Content.increaseFontSize()
    }
    
    @IBAction func onClickDecrease(_ sender: Any) {
        
        tv_Content.decreaseFontSize()
    }
    
    @IBAction func playAudioTap(_ sender: UIButton) {
        
        play_pauseAudio(button: sender, isPlay: isTapped)
        
        if isPlaying
        {
            pause()
            
        }
        else
        {
            resume()
            
        }
        
        isTapped = !isTapped
        print(isPlaying)
    }
    
    func pause()
    {
        currentPlayer?.pause()
        print("PAUSED at:", (currentPlayer?.currentTime)!)
        isPlaying = false
    }
    
    func resume()
    {
        currentPlayer?.play()
        isPlaying = true
        print("PLAY AGAIN at:", (currentPlayer?.currentTime)!)
        
    }
    
    func stop()
    {
        currentPlayer?.stop()
        isPlaying = false
        print("DID STOP")

    }
    
    @IBAction func scoreTap(_ sender: UIButton) {
        let height:CGFloat = self.view.frame.height * (2/3)
        setupViewData(subView: dataTableView, height: height)
        createAnimatePopup(from: dataTableView, with: backgroundView)
    }
    
    
    @IBAction func expandBtnTap(_ sender: Any) {
        
        let button = sender as! UIButton
        
        expand_collapesView(button: button, viewHeight: containerViewHeight, isExpanding: isExpanding, originalHeight: originalHeight)
        
        isExpanding = !isExpanding
    }

    @IBAction func nextBtnTap(_ sender: Any) {
        
        self.pause()
        self.play_pauseBtn.setImage(#imageLiteral(resourceName: "btn_play"), for: .normal)
        self.isTapped = false
        
        if score == 0 || tv_Comment.text.trimmingCharacters(in: .whitespacesAndNewlines).characters.count == 0
        {
            self.alertMissingText(mess: "Score and Comment is required.", textField: nil)
        }
        else
        {
            userDefault.set(tv_Comment.text, forKey: COMMENT_PART3)
            userDefault.synchronize()
            if self.Exam?["examQuestionaireFour"] as? String == nil
            {
                let overviewVC = UIStoryboard(name: ASSESSOR_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "overviewVC") as! Assessor_OverviewVC
                overviewVC.numberOfQuestion = 3
                overviewVC.Exam = self.Exam
                overviewVC.data1 = self.data1
                overviewVC.data2 = self.data2
                overviewVC.data3 = self.data3
                self.stop()

                self.navigationController?.pushViewController(overviewVC, animated: true)

            }
            else
            {
                let part4VC = UIStoryboard(name: ASSESSOR_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "part4VC") as! Assessor_Part4VC
                part4VC.Exam = self.Exam
                part4VC.data1 = self.data1
                part4VC.data2 = self.data2
                part4VC.data3 = self.data3
                self.navigationController?.pushViewController(part4VC, animated: true)
                
            }
            
        }
    }
    
    func setupViewData(subView: UIView, height: CGFloat)
    {
        backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        backgroundView.backgroundColor = UIColor.gray
        backgroundView.alpha = 0
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleCloseView))
        tapGesture.numberOfTapsRequired = 2
        backgroundView.addGestureRecognizer(tapGesture)
        
        view.addSubview(backgroundView)
        view.addSubview(subView)
        subView.layer.cornerRadius = 10
        
        let widthView = view.frame.size.width * (4/6)
        let heightView:CGFloat = height
        subView.frame = CGRect(x: view.frame.size.width * (1/6), y: (view.frame.size.height - heightView) / 2 , width: widthView, height: heightView)
        subView.alpha = 0
    }
    func handleCloseView()
    {
        UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
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
    }

    

}

extension Assessor_Part3VC:UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! Assessor_Part3Cell
        
        cell.lbl_Point.text = "\(indexPath.row + 1)"
        return cell
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        scoreBtn.setTitle("\(indexPath.row + 1)", for: .normal)
        userDefault.set(indexPath.row + 1, forKey: SCORE_PART3)

        score = indexPath.row + 1

        handleCloseView()

    }
}

extension Assessor_Part3VC: AVAudioPlayerDelegate
{
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("DID PLAYED")
        self.stop()
        self.play_pauseBtn.setImage(#imageLiteral(resourceName: "btn_play"), for: .normal)
        self.isTapped = false
    }
}



