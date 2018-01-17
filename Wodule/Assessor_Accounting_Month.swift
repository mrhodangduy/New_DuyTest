//
//  Assessor_Accounting_Month.swift
//  Wodule
//
//  Created by QTS Coder on 11/24/17.
//  Copyright © 2017 QTS. All rights reserved.
//

import UIKit
import Charts

class Assessor_Accounting_Month: UIViewController {

    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var monthMoneyLabel: UILabel!
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var detailsWeekTable: UITableView!
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    
    var monthlyData: NSDictionary?
    var paymenValue: [Double] = []
    var totalPayment: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        monthLabel.text = convertAccountingMonthPayment(date: Date())
        
        detailsWeekTable.register(UINib(nibName: "AccountingWeeklyCell", bundle: nil), forCellReuseIdentifier: "AccountingWeeklyCell")
        detailsWeekTable.register(UINib(nibName: "HeaderCell", bundle: nil), forCellReuseIdentifier: "HeaderCell")
        detailsWeekTable.isScrollEnabled = false
        detailsWeekTable.separatorStyle = .none
        detailsWeekTable.layer.cornerRadius = 10
        
        let monthly = monthlyData?["monthly"] as? NSDictionary
        if let month = monthly {
            monthMoneyLabel.text = "$\(month["payment"] as! String)"
        } else {
            monthMoneyLabel.text = "$0"
        }
        
        let data = monthlyData?["data"] as? [NSDictionary]
        if let weeks = data {
            for week in weeks {
                let value = Double(week["payment"] as! String)
                self.paymenValue.insert(value!, at: 0)
                self.totalPayment += value!
            }
            setupChart(paymenValue)
            self.detailsWeekTable.reloadData()
        }
        
        tableHeight.constant = CGFloat(paymenValue.count * 90 + 20)

    }
    
    func setupChart(_ data: [Double])
    {
        
        var values = [PieChartDataEntry]()
        
        for week in data {
            let entry = PieChartDataEntry(value: week, label: "")
            values.append(entry)
        }
        let dataSet = PieChartDataSet(values: values, label: nil)
        let data = PieChartData(dataSet: dataSet)
        data.setDrawValues(false)
        
        pieChartView.data = data
        pieChartView.chartDescription = nil
        pieChartView.drawHoleEnabled = false
        pieChartView.rotationEnabled = false
        
        // Color
        dataSet.colors = [#colorLiteral(red: 0.1332121491, green: 0.3832967877, blue: 0.206708461, alpha: 1),#colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1),#colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1),#colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)]
        
        // Text
        pieChartView.legend.enabled = false
        
        pieChartView.highlightPerTapEnabled = false
        
        // Refresh chart with new data
        pieChartView.notifyDataSetChanged()
        
    }
    
    @IBAction func onClickBack(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
}

extension Assessor_Accounting_Month: UITableViewDataSource, UITableViewDelegate
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return paymenValue.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountingWeeklyCell", for: indexPath) as! AccountingWeeklyCell
        
        let value = paymenValue[indexPath.section]
        cell.setupCell(value, total: totalPayment)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCell(withIdentifier: "HeaderCell") as! HeaderCell
        
        header.frame.size.width = UIScreen.main.bounds.width - 40
        header.weekLabel.text = "Week \(section + 1)"
        header.daysLabel.text = nil
        return header

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
}















