//
//  AccountingWeeklyCell.swift
//  Wodule
//
//  Created by QTS Coder on 11/24/17.
//  Copyright © 2017 QTS. All rights reserved.
//

import UIKit

class AccountingWeeklyCell: UITableViewCell {

    @IBOutlet weak var moneyLabel: UILabel!
    @IBOutlet weak var totalView: UIViewX!
    @IBOutlet weak var percentView: UIViewX!
    @IBOutlet weak var pecentWidth: NSLayoutConstraint!
    @IBOutlet weak var totalWidth: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if UIScreen.main.bounds.width == 320 {
            totalWidth.constant = 6.5/10 * 320
        } else {
            totalWidth.constant = 7/10 * UIScreen.main.bounds.width
        }
    }
    
    
    func setupCell(_ value: Double, total: Double) {
        self.layoutSubviews()
        print(totalWidth.constant)
        moneyLabel.text = "$\(value)"
        pecentWidth.constant = CGFloat(value/total) * totalWidth.constant
        print(pecentWidth.constant)
    }
}
