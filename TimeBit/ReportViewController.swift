//
//  ReportViewController.swift
//  TimeBit
//
//  Created by Krishna Alex on 4/29/17.
//  Copyright © 2017 BiteOfTime. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class ReportViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var activities: [Activity] = []
    var activityLog: [ActivityLog] = []
    
    // For the chart
    var activityForChart: [ActivityLog]!
    var count: Int64 = 0
    var arrayDataForChart = [Int64]()
    
    var activitiesLogAll: Dictionary<String, [ActivityLog]> = Dictionary()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200
        
        tableView.register(UINib(nibName: "ReportCell", bundle: nil), forCellReuseIdentifier: "ReportCell")
        
        loadActivityForUser()
        
        loadActivityLog()
        
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadActivityForUser() {
        ParseClient.sharedInstance.getActivities() { (activities: [Activity]?, error: Error?) -> Void in
            if error != nil {
                NSLog("Error getting activities from Parse")
            } else {
                NSLog("Items from Parse reportViewController")
                self.activities = activities!
                self.tableView.reloadData()
            }
            self.tableView.reloadData()
        }
    }
    
    
    func loadActivityLog() {
        ParseClient.sharedInstance.getActivities() { (activities: [Activity]?, error: Error?) -> Void in
            if error != nil {
                NSLog("Error getting activities from Parse")
            } else {
                NSLog("getActivities from Parse")
                self.activities = activities!
                
                ParseClient.sharedInstance.getActivityLog() { (activities: [ActivityLog]?, error: Error?) -> Void in
                    if error != nil {
                        NSLog("Error getting activities from Parse")
                    } else {
                        for activity in activities! {
                            var activityLogs = self.activitiesLogAll[activity.activity_name!] ?? []
                            activityLogs.append(activity)
                            self.activitiesLogAll[activity.activity_name!] = activityLogs
                            
                        }
                        NSLog("Items from Parse for getTodayCountForActivity \(self.activitiesLogAll)")
                        
                    }
                }
                self.tableView.reloadData()
            }
        }
    }
    
    
    func getTimeSpentToday(activityLog: [ActivityLog]?) -> String {
        if(activityLog == nil || activityLog?.count == 0) {
            return "0 sec"
        }
        let currentDate = Utils.formatDate(dateString: String(describing: Date()))
        var totalTimeSpentToday: Int64 = 0
        for log in activityLog! {
            if (log.activity_duration != nil && log.activity_event_date == currentDate) {
                totalTimeSpentToday += Int64(log.activity_duration!)
            }
        }
        
        return getTimeCount(duration: totalTimeSpentToday)
    }
    
    func getTimeSpentPastSevenDay(activityLog: [ActivityLog]?) -> String {
        if(activityLog == nil || activityLog?.count == 0) {
            return "0 sec"
        }
        var totalTimeSpentSevenDay: Int64 = 0
        for log in activityLog! {
            if log.activity_duration != nil {
                totalTimeSpentSevenDay += Int64(log.activity_duration!)
            }
        }
        
        var weekDateRange = self.getPastDates(days: 7)
        self.activityLog.forEach { x in
            if(weekDateRange.contains(x.activity_event_date)) {
                totalTimeSpentSevenDay += Int64(x.activity_duration!)
            }
        }
        
        return getTimeCount(duration: totalTimeSpentSevenDay)
    }
    
    func getTimeSpentTillNow(activityLog: [ActivityLog]?) -> String {
        if(activityLog == nil || activityLog?.count == 0) {
            return "0 sec"
        }
        var totalTimeSpentTillNow: Int64 = 0
        
        for log in activityLog! {
            if (log.activity_duration != nil) {
                totalTimeSpentTillNow += Int64(log.activity_duration!)
            }
        }
        
        return getTimeCount(duration: totalTimeSpentTillNow)
    }
    
    func getTimeCount(duration: Int64) -> String {
        let seconds = duration % 60
        let minutes = duration / 60
        let hours = duration / 3600
        
        if hours > 0 {
            return minutes > 0 ? "\(hours)hr \(minutes)min" : "\(hours)hr"
        }
        
        if minutes > 0 {
            return seconds > 0  ? "\(minutes)min \(seconds)sec" : "\(minutes)min"
        }
        
        return "\(seconds)sec"
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
    
    func getDataForChart(data: [String]) -> Array<Int64> {
        var arrayDate = [Int64]()
        
        //for i in data {
        for i in data {
            print(i)
            let params = ["activity_name": "Walk", "activity_event_date": i] as [String : Any]
            ParseClient.sharedInstance.getTodayCountForActivity(params: params as NSDictionary?) { (activities: [ActivityLog]?, error: Error?) -> Void in
                self.count = 0
                if error != nil {
                    NSLog("Error getting activities from Parse")
                } else {
                    self.activityForChart = activities!
                    NSLog("Items from Parse \(self.activityForChart)")
                    
                    self.activityForChart.forEach { x in
                        self.count = self.count + x.activity_duration!
                    }
                }
                arrayDate.append(self.count)
                print(self.count)
            }
        }
        return arrayDate as [Int64]
    }
    
    
    
    
    func getBarChart(data: Array<Int64>) -> PDBarChart {
        let dataItem: PDBarChartDataItem = PDBarChartDataItem()
        dataItem.xMax = 7.0
        dataItem.xInterval = 1.0
        dataItem.yMax = 100.0
        dataItem.yInterval = 10.0
        
        //var plot = getDataForChart(data: getPastDates(days: 7) as! [String])
        print("data.count \(data.count)")
        
        dataItem.barPointArray = [CGPoint(x: 1.0, y: 95.0), CGPoint(x: 2.0, y: 25.0), CGPoint(x: 3.0, y: 30.0), CGPoint(x: 4.0, y:50.0), CGPoint(x: 5.0, y: 55.0), CGPoint(x: 6.0, y: 60.0), CGPoint(x: 7.0, y: 90.0)]
        
        dataItem.xAxesDegreeTexts = getPastDates(days: 7) as! [String]
        dataItem.yAxesDegreeTexts = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J"]
        
        let frameW = self.view.frame.size.width
        let barChart: PDBarChart = PDBarChart(frame: CGRect(x: 0, y: 100, width: frameW, height: frameW), dataItem: dataItem)
        
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
        
        return barChart
    }
}

extension ReportViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activities.count
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReportCell", for: indexPath) as! ReportCell
        cell.backgroundColor = UIColor(red: 9/255, green: 37/255, blue: 62/255, alpha: 1.0)
        let activity = activities[indexPath.row]
        let pfImage = activity.activityImageFile
        if let imageFile : PFFile = pfImage{
            imageFile.getDataInBackground(block: { (data, error) in
                if error == nil {
                    let image = UIImage(data: data!)
                    cell.activityImageView.image = image
                    cell.activityImageView.image = image
                } else {
                    print(error!.localizedDescription)
                }
            })
        }
        cell.activityNameLabel.text = activity.activityName
        cell.descriptionLabel.text = activity.activityDescription
        cell.activityImageView.tintColor = .white
        cell.activityNameLabel.text = activity.activityName
        let activityLog = activitiesLogAll[activity.activityName!]
        let totalTimeSpentToday = getTimeSpentToday(activityLog: activityLog )
        cell.timespentTodayLabel.text = totalTimeSpentToday
        let totalTimePastSevenDay = getTimeSpentToday(activityLog: activityLog )
        cell.timespentInSevenDaysLabel.text = getTimeSpentPastSevenDay(activityLog: activityLog)
        let totalTimeSpentTillNow = getTimeSpentTillNow(activityLog: activityLog)
        cell.timespentTillNowLabel.text = totalTimeSpentTillNow
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 180
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        print("indexPath clicked is \(indexPath)")
        let viewCon: UIViewController = UIViewController()
        viewCon.view.backgroundColor = UIColor(red: 9/255, green: 37/255, blue: 62/255, alpha: 1.0)
        var inputData = getDataForChart(data: getPastDates(days: 7) as! [String])
        
        var chart: PDChart!
        let barChart: PDBarChart = self.getBarChart(data: inputData)
        chart = barChart
        viewCon.view.addSubview(barChart)
        
        chart.strokeChart()
        
        self.navigationController?.pushViewController(viewCon, animated: true)
        
        
    }
    
    
}
