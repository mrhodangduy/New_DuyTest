//
//  MainNavigationController.swift
//  Wodule
//
//  Created by QTS Coder on 11/8/17.
//  Copyright © 2017 QTS. All rights reserved.
//

import UIKit

class MainNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden  = true
        self.isNavigationBarHidden = true

   }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden  = true

    }
    
    

}
