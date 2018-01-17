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
    @IBOutlet weak var monthLabel: UILabel!
    
    @IBOutlet weak var todayMoneyLabel: UILabel!
    @IBOutlet weak var todayDoneLabel: UILabel!
    @IBOutlet weak var todayPendingLabel: UILabel!
    @IBOutlet weak var todayExpiredLabel: UILabel!
    @IBOutlet weak var weekMoneyLabel: UILabel!
    @IBOutlet weak var monthMoneyLabel: UILabel!
    
    
    @IBOutlet weak var dailyIndicator: UIActivityIndicatorView!
    @IBOutlet weak var weekIndicator: UIActivityIndicatorView!
    @IBOutlet weak var monthIndicator: UIActivityIndicatorView!
    
    var monthlyData: NSDictionary?
    
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
        onHandleGetTodayPaymnet()
        onHandleGetWeeksPaymnet()
        onHandleGetMonthPaymnet()
    }
    
    func onHandleGetTodayPaymnet() {
        todayLabel.text = convertAccountingTodayPayment(date: Date())
        dailyIndicator.startAnimating()
        ManageAPI_Accounting.shared.getTodayPayment(token!, onSucces: { (result: NSDictionary?) in
            
            let daily = result?["daily"] as? NSDictionary
            let data = result?["data"] as? NSDictionary
            DispatchQueue.main.async {
                self.dailyIndicator.stopAnimating()
                if daily != nil {
                    self.todayMoneyLabel.text = "$\(daily!["payment"] as! String)"
                } else {
                    self.todayMoneyLabel.text = "$0"
                }
                
                self.todayDoneLabel.text = data?["done"] as? String
                self.todayPendingLabel.text = data?["pending"] as? String
                self.todayExpiredLabel.text = data?["expired"] as? String
            }
            
        }) { (code: Int, error: NSDictionary?) in
            self.dailyIndicator.stopAnimating()
            self.onHandleError(code, error: error)
        }
    }
    
    func onHandleGetWeeksPaymnet() {
        self.weekLabel.text = Date().getMonth() + Date().getAllDaysOfLastWeeks()
        weekIndicator.startAnimating()
        ManageAPI_Accounting.shared.getWeeksPayment(token!, onSucces: { (result: NSDictionary?) in
            
            let weekly = result?["weekly"] as? NSDictionary
            let data = result?["data"] as? [NSDictionary]
            var paymentValue:[Double] = []
            if data?.isEmpty != true {
                for day in data! {
                    let value = day["payment"] as! String
                    paymentValue.append(Double(value)!)
                }
            }
            
            DispatchQueue.main.async {
                self.weekIndicator.stopAnimating()
                if weekly != nil {
                    self.weekMoneyLabel.text = "$\(weekly!["payment"] as! String)"
                }
                else {
                    self.weekMoneyLabel.text = "$0"
                }
                
                if !paymentValue.isEmpty {
                    self.setChart(paymentValue)
                }
            }
            
        }) { (code: Int, error: NSDictionary?) in
            self.weekIndicator.stopAnimating()
        }
    }
    
    func onHandleGetMonthPaymnet() {
        monthLabel.text = convertAccountingMonthPayment(date: Date())
        monthIndicator.startAnimating()
        ManageAPI_Accounting.shared.getMonthPayment(token!, onSucces: { (result: NSDictionary?) in
            
            self.monthlyData = result
            
            let monthly = result?["monthly"] as? NSDictionary
            let data = result?["data"] as? [NSDictionary]
            var paymentValue:[Double] = []
            if data?.isEmpty != true {
                for week in data! {
                    let value = week["payment"] as! String
                    paymentValue.append(Double(value)!)
                }
            }
            
            DispatchQueue.main.async {
                self.monthIndicator.stopAnimating()
                if monthly != nil {
                    self.monthMoneyLabel.text = "$\(monthly!["payment"] as! String)"
                }
                else {
                    self.monthMoneyLabel.text = "$0"
                }
                
                if !paymentValue.isEmpty {
                    self.setupPieChart(paymentValue)
                }
            }
            
        }) { (code: Int, error: NSDictionary?) in
            self.monthIndicator.stopAnimating()
        }
    }
    
    func onHandleError(_ code: Int, error: NSDictionary?) {
        if code == 429
        {
            DispatchQueue.main.async(execute: {
                self.loadingHide()
                self.alertMissingText(mess: "Too Many Attempts\n(ErrorCode:\(429))", textField: nil)
            })
        }
            
        else if code == 401
        {
            if let error = error?["error"] as? String
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
    
    func setChart(_ data: [Double]) {
        
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
        
        var values = [BarChartDataEntry]()
        
        values = setupFakeData(data.count, data: data)

        let dataSet = BarChartDataSet(values: values, label: nil)
        let data = BarChartData(dataSets: [dataSet])
        data.barWidth = 0.95
        data.setDrawValues(false)
        barChartView.data = data        
        
        // Color
        dataSet.colors = [#colorLiteral(red: 0.1332121491, green: 0.3832967877, blue: 0.206708461, alpha: 1)]
        
        // Refresh chart with new data
        barChartView.notifyDataSetChanged()
        
    }
    
    func setupFakeData(_ number: Int, data: [Double]) -> [BarChartDataEntry] {
        
        var values = [BarChartDataEntry]()
        for i in 0..<data.count {
            let entry = BarChartDataEntry(x: Double(i + 1), y: data[i])
            values.append(entry)
        }
        
        switch number {
        case 1:
            for i in 2...7 {
                let entry = BarChartDataEntry(x: Double(i), y: 0.0)
                values.append(entry)
            }
            return values
        case 2:
            for i in 3...7 {
                let entry = BarChartDataEntry(x: Double(i), y: 0.0)
                values.append(entry)
            }
            return values
        case 3:
            for i in 4...7 {
                let entry = BarChartDataEntry(x: Double(i), y: 0.0)
                values.append(entry)
            }
            return values
        case 4:
            for i in 5...7 {
                let entry = BarChartDataEntry(x: Double(i), y: 0.0)
                values.append(entry)
            }
            return values
        case 5:
            for i in 6...7 {
                let entry = BarChartDataEntry(x: Double(i), y: 0.0)
                values.append(entry)
            }
            return values
        case 6:
            let entry = BarChartDataEntry(x: Double(7), y: 0.0)
            values.append(entry)
            return values
        default:
            return values
        }
        
        
    }

    
    
    func setupPieChart(_ data:[Double])
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
        pieChartView.animate(xAxisDuration: 0.2)
        pieChartView.rotationEnabled = false
        
        // Color
        dataSet.colors = [#colorLiteral(red: 0.1332121491, green: 0.3832967877, blue: 0.206708461, alpha: 1),#colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1),#colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1), #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1), #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)]
        
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
        
        accounting_monthVC.monthlyData = self.monthlyData
        
        self.navigationController?.pushViewController(accounting_monthVC, animated: true)
    }
    
}
