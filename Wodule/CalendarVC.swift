//
//  CalendarVC.swift
//  Wodule
//
//  Created by QTS Coder on 10/3/17.
//  Copyright © 2017 QTS. All rights reserved.
//

import UIKit
import FSCalendar

class CalendarVC: UIViewController {

    @IBOutlet weak var calendarView: FSCalendar!
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!    
    @IBOutlet weak var eventTableView: UITableView!
    @IBOutlet weak var eventTableHeight: NSLayoutConstraint!
    
    @IBOutlet weak var eventDetailView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var eventDetailsViewHeight: NSLayoutConstraint!
    let cellHeight:CGFloat = 35

    var calendarList = [NSDictionary]()
    let token = userDefault.object(forKey: TOKEN_STRING) as? String
    
    fileprivate let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
    
    fileprivate lazy var dateFormatter2: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    fileprivate let gregorian: NSCalendar! = NSCalendar(calendarIdentifier:NSCalendar.Identifier.gregorian)
    
    var dateWithEvent = [String:String]()
    var dateWithEventDetails = [String: String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        NotificationCenter.default.addObserver(self, selector: #selector(self.onHandleInitData), name: NSNotification.Name.available, object: nil)
        
        eventDetailsViewHeight.constant = 0
        eventDetailView.alpha = 0
        
        eventTableView.register(UINib(nibName: "EventCell", bundle: nil), forCellReuseIdentifier: "EventCell")
        eventTableView.dataSource = self
        eventTableView.delegate = self
        if Connectivity.isConnectedToInternet
        {
            self.onHandleInitData()
        }
        else
        {
            self.displayAlertNetWorkNotAvailable()
        }
        
        self.calendarView.dataSource = self
        self.calendarView.delegate = self
    
    }
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    func onHandleInitData()
    {
        self.loadingShow()
        DispatchQueue.global(qos: .background).async {
            
            ManageAPI_Calendar.shared.getCalendar(token: self.token!, completion: { (status:Bool, code: Int, results: NSDictionary?) in
                
                if status
                {
                    if let data = results?["data"] as? [NSDictionary]
                    {
                        for item in data
                        {
                            self.calendarList.insert(item, at: 0)
                            let day = self.onHandleSubDate(string: item["date"] as? String)
                            let time = self.convertTimeEvent(DateString: (item["date"] as? String)!)
                            let details = item["details"] as? String
                            self.dateWithEventDetails.updateValue(details!, forKey: day!)
                            self.dateWithEvent.updateValue(time, forKey: day!)
                        }
                        DispatchQueue.main.async(execute: {
                            self.eventTableHeight.constant = self.cellHeight * CGFloat(self.calendarList.count)
                            self.loadingHide()
                            self.eventTableView.reloadData()
                            self.calendarView.reloadData()
                            print(self.dateWithEventDetails)
                            
                        })
                    }
                } else if code == 429
                {
                    DispatchQueue.main.async(execute: {
                        self.loadingHide()
                        self.alertMissingText(mess: "Too Many Attempts\n(ErrorCode:\(429))", textField: nil)
                    })
                    
                }
                else if code == 401
                {
                    self.loadingHide()
                    if let error = results?["error"] as? String
                    {
                        if error.contains("Token")
                        {
                            self.onHandleTokenInvalidAlert()
                        }
                    }
                    
                }
                else
                {
                    self.loadingHide()
                }
                
            })
            
        }
    }
    
    func onHandleSubDate(string: String?) -> String?
    {
        let str = string
        let index = str?.index((str?.startIndex)!, offsetBy: 10)
        return str?.substring(to: index!)
    }

    @IBAction func backBtnTap(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func calendarBackTap(_ sender: Any) {
        
        print("Back")
        if  let prePage = self.gregorian.date(byAdding: .month, value: -1, to: calendarView.currentPage, options: .init(rawValue: 0)) {
            calendarView.setCurrentPage(prePage, animated: true)            
        }
    }
    @IBAction func calendaNextTap(_ sender: Any) {
        print("Next")
        if  let nextPage = self.gregorian.date(byAdding: .month, value: 1, to: calendarView.currentPage, options: .init(rawValue: 0)) {
            calendarView.setCurrentPage(nextPage, animated: true)
            
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension CalendarVC: FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance
{
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.calendarHeightConstraint.constant = bounds.height
        self.view.layoutIfNeeded()
    }    
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        
        let dateString = self.dateFormatter2.string(from: date)
        if (self.dateWithEvent[dateString] != nil)
        {
            return UIColor.red
        }
        return nil
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        let dateString2 = self.dateFormatter2.string(from: date)
        print("Selected", dateString2)
        
        if (self.dateWithEventDetails[dateString2] != nil)
        {
            self.timeLabel.text = dateWithEvent[dateString2]
            self.titleLabel.text = dateWithEventDetails[dateString2]
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
                self.eventDetailView.alpha = 1
                self.eventDetailsViewHeight.constant = 50
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
        else
        {
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
                self.eventDetailView.alpha = 0
                self.eventDetailsViewHeight.constant = 0
                self.view.layoutIfNeeded()

            }, completion: nil)
        }
        
    }
}


extension CalendarVC: UITableViewDelegate, UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calendarList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventCell
        
        let event = calendarList[indexPath.row]
        
        cell.titleEventLabel.text = event["title"] as? String
        cell.dateEventLabel.text = convertDayEvent(DateString: event["date"] as! String)
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
}

















