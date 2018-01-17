//
//  Assessor_Part4VC.swift
//  Wodule
//
//  Created by QTS Coder on 10/4/17.
//  Copyright © 2017 QTS. All rights reserved.
//

import UIKit
import AVFoundation

class Offline_Part4: UIViewController {

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
    var Exam: ExamDataStruct!

    var isExpanding:Bool!
    var originalHeight:CGFloat!
    var isPlaying:Bool!
    var currentPlayer: AVAudioPlayer?
    var isTapped:Bool!

    var data1: Data?
    var data2: Data?
    var data3: Data?
    var data4: Data?
    
    func onHandleSetupAudio()
    {
        currentPlayer = AVAudioPlayer()
            let url = getAudioUrlOffline(saveName: "audio_4", examinerId: Exam.examinerId, identifier: Exam.identifier)
            play_pauseBtn.isHidden = true
            self.loadingShow()
            DispatchQueue.global(qos: .background).async {
                do
                {
                    self.data4 = try Data(contentsOf: url)
                    do {
                        self.currentPlayer = try AVAudioPlayer(data: self.data4!)
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
                        DispatchQueue.main.async(execute: {
                            self.currentPlayer = nil
                            self.loadingHide()
                            self.alertMissingText(mess: ERROR_MESSAGE.CANNOTPLAY_AUDIO, textField: nil)
                            
                        })
                    }
                }
                catch
                {
                    print("Cannot get data")
                    DispatchQueue.main.async(execute: {
                        self.currentPlayer = nil
                        self.loadingHide()
                        self.alertMissingText(mess: ERROR_MESSAGE.CANNOTPLAY_AUDIO, textField: nil)
                        
                    })
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
        tv_Content.contentInset = UIEdgeInsetsMake(10, 0, 25, 0)

        if ((Exam.examQuestionaireFour)?.hasPrefix("http://wodule.io/user/"))!
        {
            img_Question.isHidden = false
            titleQuestion.text = TITLEPHOTO
            let url = getImageQuestionUrlOffline(saveName: "question_4", examinerId: Exam.examinerId, identifier: Exam.identifier)
            img_Question.sd_setImage(with: url, placeholderImage: nil, options: [], completed: nil)
            controlFontSizeView.isHidden = true
            controlImageView.isHidden = false
            tv_Content.isHidden = true
        }
        else
        {
            tv_Content.isScrollEnabled = false
            titleQuestion.text = TITLESTRING
            img_Question.isHidden = true
            controlFontSizeView.isHidden = false
            controlImageView.isHidden = true
            tv_Content.isHidden = false
            tv_Content.textContainerInset = UIEdgeInsetsMake(15, 20, 32, 10)
            tv_Content.text = Exam.examQuestionaireFour!
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tv_Content.isScrollEnabled = true
    }
    
    @IBAction func onClickPromtQuestion(_ sender: Any) {
        
    }
    
    
    @IBAction func onClickDecrease(_ sender: Any) {
        
        tv_Content.decreaseFontSize()
    }
    
    @IBAction func onClickIncrease(_ sender: Any) {
        tv_Content.increaseFontSize()
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
        
        if currentPlayer != nil
        {
            self.pause()
            self.play_pauseBtn.setImage(#imageLiteral(resourceName: "btn_play"), for: .normal)
            self.isTapped = false
        }
        
        if score == 0 || tv_Comment.text.trimmingCharacters(in: .whitespacesAndNewlines).characters.count == 0
        {
            self.alertMissingText(mess: "Score and Comment is required.", textField: nil)
        }
        else
        {
            if currentPlayer != nil
            {
                self.stop()
            }
            userDefault.set(tv_Comment.text, forKey: COMMENT_PART4)
            userDefault.synchronize()
            let overviewVC = UIStoryboard(name: OFFLINE_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "overviewVC") as! Offline_OverviewVC
            overviewVC.numberOfQuestion = 4
            overviewVC.Exam = self.Exam
            overviewVC.data1 = self.data1
            overviewVC.data2 = self.data2
            overviewVC.data3 = self.data3
            overviewVC.data4 = self.data4
            self.navigationController?.pushViewController(overviewVC, animated: true)

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


}


extension Offline_Part4:UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! Assessor_Part4Cell
        
        cell.lbl_Point.text = "\(indexPath.row + 1)"
        return cell
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        scoreBtn.setTitle("\(indexPath.row + 1)", for: .normal)
        userDefault.set(indexPath.row + 1, forKey: SCORE_PART4)

        score = indexPath.row + 1

        handleCloseView()

    }
}

extension Offline_Part4: AVAudioPlayerDelegate
{
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("DID PLAYED")
        self.stop()
        self.play_pauseBtn.setImage(#imageLiteral(resourceName: "btn_play"), for: .normal)
        self.isTapped = false
    }
}
