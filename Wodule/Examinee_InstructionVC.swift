//
//  Examinee_InstructionVC.swift
//  Wodule
//
//  Created by QTS Coder on 10/27/17.
//  Copyright © 2017 QTS. All rights reserved.
//

import UIKit
import JWGCircleCounter

class Examinee_InstructionVC: UIViewController {

    @IBOutlet weak var circleView: JWGCircleCounter!
    @IBOutlet weak var instroductionTextView: UITextView!
    
    var Exam:NSDictionary?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        circleView.circleTimerWidth = 2
        circleView.circleBackgroundColor = .clear
        circleView.circleColor = .white

        instroductionTextView.textContainerInset = UIEdgeInsetsMake(20, 20, 10, 10)
        if Connectivity.isConnectedToInternet
        {
            loadingShow()
            Categories.getCategory { (status:Bool, results:NSDictionary?) in
                
                if status
                {
                    if let result = results
                    {
                        print("Result:", result)
                        self.Exam = result
                        DispatchQueue.main.async(execute: {
                            self.instroductionTextView.text = result["instruction"] as? String
                            self.loadingHide()
                        })
                    }
                }
                else
                {
                    self.loadingHide()
                    self.alertMissingText(mess: "Something went wrong", textField: nil)
                    print(results as Any)
                }
                
            }
        }
        else
        {
            self.displayAlertNetWorkNotAvailable()
        }

    }
    @IBAction func onClickNext(_ sender: Any) {
        
        let part1VC = UIStoryboard(name: EXAMINEE_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "part1VC") as! Part1VC
        
        part1VC.Exam = self.Exam
        
        self.navigationController?.pushViewController(part1VC, animated: true)

        
    }

    @IBAction func onClickIncrease(_ sender: Any) {
        
        instroductionTextView.font = UIFont.systemFont(ofSize: (instroductionTextView.font?.pointSize)! + 1)
        
    }
    
    @IBAction func onClickDecrease(_ sender: Any) {
        
        if Int((instroductionTextView.font?.pointSize)!) > 10
        {
            instroductionTextView.font = UIFont.systemFont(ofSize: (instroductionTextView.font?.pointSize)! - 1)
        }
    }
}
