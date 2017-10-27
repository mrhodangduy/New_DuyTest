//
//  Instruction_GuideVC.swift
//  Wodule
//
//  Created by QTS Coder on 10/3/17.
//  Copyright © 2017 QTS. All rights reserved.
//

import UIKit

class Instruction_GuideVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func countinueTap(_ sender: UITapGestureRecognizer) {
        
        let instruction_guideVC = UIStoryboard(name: EXAMINEE_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "introductionsVC") as! Examinee_InstructionVC
        self.navigationController?.pushViewController(instruction_guideVC, animated: true)
        
    }

}
