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
    //var activity_name: String!
    var activity_name: String = "Dance"
    var activityToday: [ActivityLog]!
    var today_Count: String?
    var tillDate_Count: String?
    var countDuration: Int64 = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "DetailActivity1Cell", bundle: nil), forCellReuseIdentifier: "DetailActivity1Cell")
        tableView.register(UINib(nibName: "DetailActivity2Cell", bundle: nil), forCellReuseIdentifier: "DetailActivity2Cell")
        tableView.register(UINib(nibName: "DetailActivity3Cell", bundle: nil), forCellReuseIdentifier: "DetailActivity3Cell")
        tableView.register(UINib(nibName: "DetailActivity4Cell", bundle: nil), forCellReuseIdentifier: "DetailActivity4Cell")
        
        // Today's activity update
        todayCount()
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
        print("currentDate is \(currentDate)")
        
        let params = ["activity_name": activity_name, "activity_event_date": currentDate] as [String : Any]
        
        ParseClient.sharedInstance.getTodayCountForActivity(params: params as NSDictionary?) { (activities: [ActivityLog]?, error: Error?) -> Void in
            if error != nil {
                NSLog("Error getting activities from Parse")
            } else {
                self.activityToday = activities!
                NSLog("Items from Parse \(self.activityToday)")
                var countDuration: Int64 = 0
                
                self.activityToday.forEach { x in
                    countDuration = countDuration + x.activity_duration!
                }
                
                let seconds = self.countDuration % 60
                let minutes = self.countDuration / 60
                let hours = self.countDuration / 3600
                
                if hours > 0 {
                    self.today_Count = minutes > 0 ? "\(hours) hr \(minutes) min today" : "\(hours) hr today"
                } else if minutes > 0 {
                    self.today_Count = seconds > 0  ? "\(minutes) min \(seconds) sec today" : "\(minutes) min today"
                } else {
                    self.today_Count = "\(seconds) sec today"
                }
            }
            
            print("output of today_Count inside \(self.today_Count)")
        }
        print("output1 \(self.today_Count)")
    }
    
    func formatDate(dateString: String) -> String? {
        
        let formatter = DateFormatter()
        let currentDateFormat = DateFormatter.dateFormat(fromTemplate: "MMddyyyy", options: 0, locale: NSLocale(localeIdentifier: "en-GB") as Locale)
        
        formatter.dateFormat = currentDateFormat
        let formattedDate = formatter.string(from: Date())
        // contains the string "22/06/2014".
        
        return formattedDate
    }
    
    func tillDateCount(){
        tillDate_Count = "0 sec"
        var currentDate = formatDate(dateString: String(describing: Date()))
        print("currentDate is \(currentDate)")
        
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
                self.tillDate_Count = String(self.countDuration)
                //self.tillDate_Count = String(self.countDuration) + "sec"
                
                let seconds = self.countDuration % 60
                let minutes = self.countDuration / 60
                let hours = self.countDuration / 3600
                
                if hours > 0 {
                    self.tillDate_Count = minutes > 0 ? "\(hours) hr \(minutes) min today" : "\(hours) hr today"
                } else if minutes > 0 {
                    self.tillDate_Count = seconds > 0  ? "\(minutes) min \(seconds) sec today" : "\(minutes) min today"
                } else {
                    self.tillDate_Count = "\(seconds) sec today"
                }
            }
            
            print("output tillDate_Count inside \(self.tillDate_Count)")
        }
        print("output \(tillDate_Count)")
        //return tillDate_Count!
    }
    
    func getTimeSpentToday(activityLog: [ActivityLog]?) -> String {
        if(activityLog == nil || activityLog?.count == 0) {
            return "0"
        }
        var totalTimeSpentToday: Int64 = 0
        for log in activityLog! {
            if log.activity_duration != nil {
                totalTimeSpentToday += Int64(log.activity_duration!)
            }
        }
        let seconds = totalTimeSpentToday % 60
        let minutes = totalTimeSpentToday / 60
        let hours = totalTimeSpentToday / 3600
        //print("totalTimeSpentToday:", totalTimeSpentToday)
        
        if hours > 0 {
            return minutes > 0 ? "\(hours) hr \(minutes) min today" : "\(hours) hr today"
        }
        
        if minutes > 0 {
            return seconds > 0  ? "\(minutes) min \(seconds) sec today" : "\(minutes) min today"
        }
        
        return "\(seconds) sec today"
        
    }

}

extension DetailActivityViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("section \(indexPath.section)")
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailActivity1Cell", for: indexPath) as! DetailActivity1Cell
            cell.dailyCount?.text = today_Count
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
//            let gvc = GoalSettingViewController(nibName: "GoalSettingViewController", bundle: nil)
//            gvc.activityName = activity_name
//            navigationController?.pushViewController(gvc, animated: true);
        }
        
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        if indexPath.section == 0 {
            return 120
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
