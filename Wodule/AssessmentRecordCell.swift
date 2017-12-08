//
//  AssessmentRecordCell.swift
//  Wodule
//
//  Created by QTS Coder on 12/8/17.
//  Copyright © 2017 QTS. All rights reserved.
//

import UIKit

class AssessmentRecordCell: UITableViewCell {

    @IBOutlet weak var examIDLabel: UILabel!
    @IBOutlet weak var startButton: UIButtonX!
    override func awakeFromNib() {
        super.awakeFromNib()
        startButton.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func onClickStart(_ sender: Any) {
    }
    
}
