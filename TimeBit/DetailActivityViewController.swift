//
//  DetailActivityViewController.swift
//  TimeBit
//
//  Created by Namrata Mehta on 4/29/17.
//  Copyright © 2017 BiteOfTime. All rights reserved.
//

import UIKit

class DetailActivityViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var detailActivity1Cell: DetailActivity1Cell!
    var detailActivity4Cell: DetailActivity4Cell!
    // Expecting this value from the calling screen.
    var activity_name: String!
    //var activity_name: String = "Sport"
    var activityToday: [ActivityLog]!
    var today_Count: String?
    var tillDate_Count: String?
    var weekly_count: String?
    var countDuration: Int64 = 0
    var countDurationToday: Int64 = 0
    var countDurationWeekly: Int64 = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.navigationItem.title = activity_name
        
        tableView.register(UINib(nibName: "DetailActivity1Cell", bundle: nil), forCellReuseIdentifier: "DetailActivity1Cell")
        tableView.register(UINib(nibName: "DetailActivity2Cell", bundle: nil), forCellReuseIdentifier: "DetailActivity2Cell")
        tableView.register(UINib(nibName: "DetailActivity3Cell", bundle: nil), forCellReuseIdentifier: "DetailActivity3Cell")
        tableView.register(UINib(nibName: "DetailActivity4Cell", bundle: nil), forCellReuseIdentifier: "DetailActivity4Cell")
        
        todayCount()
        getWeeklyCountForActivity()
        tillDateCount()
        
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func todayCount(){
        today_Count = "0 sec"
        var currentDate = formatDate(dateString: String(describing: Date()))
        let params = ["activity_name": activity_name, "activity_event_date": currentDate] as [String : Any]
        
        ParseClient.sharedInstance.getTodayCountForActivity(params: params as NSDictionary?) { (activities: [ActivityLog]?, error: Error?) -> Void in
            if error != nil {
                NSLog("Error getting activities from Parse")
            } else {
                self.activityToday = activities!
                NSLog("Items from Parse \(self.activityToday)")
                
                self.activityToday.forEach { x in
                    self.countDurationToday = self.countDurationToday + x.activity_duration!
                }
                
                self.today_Count = self.calculateCount(duration: self.countDurationToday)
            }
            
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
            })
            
        }
    }
    
    func formatDate(dateString: String) -> String? {
        
        let formatter = DateFormatter()
        let currentDateFormat = DateFormatter.dateFormat(fromTemplate: "MMddyyyy", options: 0, locale: NSLocale(localeIdentifier: "en-GB") as Locale)
        
        formatter.dateFormat = currentDateFormat
        let formattedDate = formatter.string(from: Date())
        // contains the string "22/06/2014".
        
        return formattedDate
    }
    
    func tillDateCount() {
        tillDate_Count = "0 sec"
        var currentDate = formatDate(dateString: String(describing: Date()))
        
        let params = ["activity_name": activity_name] as [String : Any]
        
        ParseClient.sharedInstance.getTotalCountForActivity(params: params as NSDictionary?) { (activities: [ActivityLog]?, error: Error?) -> Void in
            if error != nil {
                NSLog("Error getting activities from Parse")
            } else {
                self.activityToday = activities!
                NSLog("Items from Parse \(self.activityToday)")
                
                self.activityToday.forEach { x in
                    self.countDuration = self.countDuration + x.activity_duration!
                }
                
                self.tillDate_Count = self.calculateCount(duration: self.countDuration)
            }
            
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
            })
        }
    }
    
    func getWeeklyCountForActivity() {
        weekly_count = "0 sec"
        
        let params = ["activity_name": activity_name] as [String : Any]
        
        ParseClient.sharedInstance.getTotalCountForActivity(params: params as NSDictionary?) { (activities: [ActivityLog]?, error: Error?) -> Void in
            if error != nil {
                NSLog("Error getting activities from Parse")
            } else {
                self.activityToday = activities!
                NSLog("Items from Parse \(self.activityToday)")
                
                var weekDateRange = self.getPastDates(days: 7)
                
                self.activityToday.forEach { x in
                    if(weekDateRange.contains(x.activity_event_date)) {
                        self.countDurationWeekly = self.countDurationWeekly + x.activity_duration!
                    }
                }
                self.weekly_count = self.calculateCount(duration: self.countDurationWeekly)
            }
            
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
            })
        }
    }
    
    func calculateCount(duration: Int64) -> String {
        var displayStr = "0 sec"
        let seconds = duration % 60
        let minutes = duration / 60
        let hours = duration / 3600
        
        if hours > 0 {
            displayStr = minutes > 0 ? "\(hours) hr \(minutes) min" : "\(hours) hr"
        } else if minutes > 0 {
            displayStr = seconds > 0  ? "\(minutes) min \(seconds) sec" : "\(minutes) min"
        } else {
            displayStr = "\(seconds) sec"
        }
        
        return displayStr
    }
    
    func getPastDates(days: Int) -> NSArray {
        let cal = NSCalendar.current
        var today = cal.startOfDay(for: Date())
        var arrayDate = [String]()
        
        for i in 1 ... days {
            let day = cal.component(.day, from: today)
            let month = cal.component(.month, from: today)
            let year = cal.component(.year, from: today)
            
            var dayInString: String = "00"
            var monthInString: String = "00"
            if day <= 9 {
                dayInString = "0"+String(day)
            } else {
                dayInString = String(day)
            }
            if month <= 9 {
                monthInString = "0"+String(month)
            } else {
                monthInString = String(month)
            }
            
            arrayDate.append(dayInString + "/" + monthInString+"/" + String(year))
                        // move back in time by one day:
            today = cal.date(byAdding: .day, value: -1, to: today)!
        }
        return arrayDate as NSArray
    }
    
}

extension DetailActivityViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailActivity1Cell", for: indexPath) as! DetailActivity1Cell
            cell.todayView?.layer.borderColor = UIColor.white.cgColor
            cell.todayView?.layer.borderWidth = 3
            
            cell.weeklyView?.layer.borderColor = UIColor.white.cgColor
            cell.weeklyView?.layer.borderWidth = 3
            
            cell.tillDateView?.layer.borderColor = UIColor.white.cgColor
            cell.tillDateView?.layer.borderWidth = 3
            
            cell.dailyCount?.text = today_Count
            cell.weeklyCount?.text = weekly_count
            cell.sinceCreationCount?.text = tillDate_Count
            
            return cell
        }
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailActivity2Cell", for: indexPath) as! DetailActivity2Cell
            return cell
        }
        if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailActivity3Cell", for: indexPath) as! DetailActivity3Cell
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailActivity4Cell", for: indexPath) as! DetailActivity4Cell
            cell.activity_name = activity_name
            return cell
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 1 {
            print("Set/Update a goal")
            let gvc = GoalSettingViewController(nibName: "GoalSettingViewController", bundle: nil)
            gvc.activityName = activity_name
            navigationController?.pushViewController(gvc, animated: true);
        } else if indexPath.section == 2 {
            print("Share with friends")
        }
        
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        if indexPath.section == 0 {
            return 180
        }
        else if indexPath.section == 1 {
            return 60
        }
        else if indexPath.section == 2 {
            return 60
        }
        else if indexPath.section == 3 {
            return 300
        }
        return 10
    }
    
    
}
