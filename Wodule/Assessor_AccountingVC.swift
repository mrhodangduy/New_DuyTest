//
//  Assessor_AccountingVC.swift
//  Wodule
//
//  Created by QTS Coder on 10/4/17.
//  Copyright © 2017 QTS. All rights reserved.
//

import UIKit
import Charts

class Assessor_AccountingVC: UIViewController {
    
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var todayLabel: UILabel!
    @IBOutlet weak var weekLabel: UILabel!
    
    @IBOutlet weak var todayMoneyLabel: UILabel!
    @IBOutlet weak var todayDoneLabel: UILabel!
    @IBOutlet weak var todayPendingLabel: UILabel!
    @IBOutlet weak var todayExpiredLabel: UILabel!
    @IBOutlet weak var weekMoneyLabel: UILabel!
    
    
    var dayInWeek = ["","","","","","",""]
    
    var Accounting: NSDictionary?
    let token = userDefault.object(forKey: TOKEN_STRING) as? String
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Connectivity.isConnectedToInternet
        {
            self.onHandleInitData()
        }
        else
        {
            self.displayAlertNetWorkNotAvailable()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.onHandleInitData), name: NSNotification.Name.available, object: nil)
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    func onHandleInitData()
    {
        self.loadingShow()
        ManageAPI_Accounting.shared.getAccounting(witkToken: token!, type: "daily") { (status: Bool,code:Int?, result:NSDictionary?) in
            
            print(result as Any)
            
            if status
            {
                DispatchQueue.main.async(execute: {
                    self.loadingHide()
                    self.setChart()
                    self.setupPieChart()

                })
            } else if code == 429
            {
                DispatchQueue.main.async(execute: {
                    self.loadingHide()
                    self.alertMissingText(mess: "Too Many Attempts\n(ErrorCode:\(429))", textField: nil)
                })
                
            }
                
            else if code == 401
            {
                
                if let error = result?["error"] as? String
                {
                    if error.contains("Token")
                    {
                        self.loadingHide()
                        self.onHandleTokenInvalidAlert()
                    }
                }
                
            }
            else
            {
                self.loadingHide()
                self.alertMissingText(mess: "Something went wrong.", textField: nil)
            }
            
            
        }

    }
    
    func setChart() {
        
        barChartView.noDataText = "No data for this week."
        barChartView.highlightFullBarEnabled = false
        barChartView.setScaleEnabled(false)
        barChartView.xAxis.enabled = false
        barChartView.leftAxis.enabled = false
        barChartView.rightAxis.enabled = false
        barChartView.chartDescription = nil
        barChartView.legend.enabled = false
        barChartView.fitBars = true
        barChartView.animate(xAxisDuration: 0.5)
        
        let entry1 = BarChartDataEntry(x: 1.0, y: Double(45))
        let entry2 = BarChartDataEntry(x: 2.0, y: Double(48))
        let entry3 = BarChartDataEntry(x: 3.0, y: Double(42))
        let entry4 = BarChartDataEntry(x: 4.0, y: Double(45))
        let entry5 = BarChartDataEntry(x: 5.0, y: Double(58))
        let entry6 = BarChartDataEntry(x: 6.0, y: Double(38))
        let entry7 = BarChartDataEntry(x: 7.0, y: Double(48.5))

        let dataSet = BarChartDataSet(values: [entry1, entry2, entry3,entry4,entry5,entry6,entry7], label: nil)
        let data = BarChartData(dataSets: [dataSet])
        data.barWidth = 0.95
        data.setDrawValues(false)
        barChartView.data = data        
        
        // Color
        dataSet.colors = [#colorLiteral(red: 0.1332121491, green: 0.3832967877, blue: 0.206708461, alpha: 1)]
            
        
        // Refresh chart with new data
        barChartView.notifyDataSetChanged()
        
    }
    func setupPieChart()
    {
        
        let entry1 = PieChartDataEntry(value: Double(120), label: "")
        let entry2 = PieChartDataEntry(value: Double(480), label: "")
        let entry3 = PieChartDataEntry(value: Double(100), label: "")
        
        let dataSet = PieChartDataSet(values: [entry1, entry2, entry3], label: nil)
        let data = PieChartData(dataSet: dataSet)
        data.setDrawValues(false)
        
        pieChartView.data = data
        pieChartView.chartDescription = nil
        pieChartView.drawHoleEnabled = false
        pieChartView.animate(xAxisDuration: 0.2)
        pieChartView.rotationEnabled = false
        
        // Color
        dataSet.colors = [#colorLiteral(red: 0.1332121491, green: 0.3832967877, blue: 0.206708461, alpha: 1),#colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1),#colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)]
        
        // Text
        pieChartView.legend.enabled = false
        pieChartView.highlightPerTapEnabled = false

        // Refresh chart with new data
        pieChartView.notifyDataSetChanged()
        
        
    }

    
    @IBAction func backtoHomeTap(_ sender: Any) {
        
        guard let viewControllers: [UIViewController] = self.navigationController?.viewControllers else {return}
        for assessor_homeVC in viewControllers {
            if assessor_homeVC is Assessor_HomeVC {
                self.navigationController!.popToViewController(assessor_homeVC, animated: true)
                break
            }
        }
        
    }
    
    
    @IBAction func onClickTemp(_ sender: Any) {
        
        let accounting_monthVC = UIStoryboard(name: ASSESSOR_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "accounting_monthVC") as! Assessor_Accounting_Month
        
        self.navigationController?.pushViewController(accounting_monthVC, animated: true)
    }
    
}

















