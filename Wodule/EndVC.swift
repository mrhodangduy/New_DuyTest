//
//  EndVC.swift
//  Wodule
//
//  Created by QTS Coder on 10/3/17.
//  Copyright © 2017 QTS. All rights reserved.
//

import UIKit

class EndVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func backToHomeTap(_ sender: Any) {
        
        guard let viewControllers: [UIViewController] = self.navigationController?.viewControllers else {return}
        for examinerVC in viewControllers {
            if examinerVC is Examiner_HomeVC {
                self.navigationController!.popToViewController(examinerVC, animated: true)
                break
            }
        }
    }
    
    @IBAction func takeAnotherTap(_ sender: Any) {
        
        guard let viewControllers: [UIViewController] = self.navigationController?.viewControllers else {return}
        for examinerVC in viewControllers {
            if examinerVC is Examiner_HomeVC {
                self.navigationController!.popToViewController(examinerVC, animated: true)
                break

            }
        }
        
    }

}
