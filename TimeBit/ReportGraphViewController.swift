//
//  ReportGraphViewController.swift
//  TimeBit
//
//  Created by Namrata Mehta on 5/8/17.
//  Copyright © 2017 BiteOfTime. All rights reserved.
//

import UIKit
import Charts
import Parse
import ParseUI

class ReportGraphViewController: UIViewController, ChartViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var graphView: BarChartView!
    
    var activity_name = "Internet"
    var activities: [Activity] = []
    var activityLog: [ActivityLog] = []
    
    // For the chart
    var activityForChart: [ActivityLog]!
    var count: Int64 = 0
    var arrayDataForChart = [Int64]()
    var durationForCharts: [Double] = []
    
    var activitiesLogAll: Dictionary<String, [ActivityLog]> = Dictionary()
    
    var months: [String]!
    var yAxisCount: [Double] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Activity Report"
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200
        
        tableView.register(UINib(nibName: "ActivityReportCell", bundle: nil), forCellReuseIdentifier: "ActivityReportCell")
        
        //Adding code to load the graph skeleton
        self.months = ["Wed", "Tue", "Mon", "Sun", "Sat", "Fri", "Thr"]
        
        self.graphView.animate(yAxisDuration: 1.0)
        self.graphView.pinchZoomEnabled = false
        self.graphView.drawBarShadowEnabled = false
        self.graphView.drawBordersEnabled = false
        self.graphView.chartDescription?.text = ""
        //self.graphView.chartDescription?.text = self.activity_name
        
        let xAxis:XAxis = self.graphView.xAxis
        xAxis.drawAxisLineEnabled = false
        xAxis.drawGridLinesEnabled = false
        xAxis.labelTextColor = UIColor.white
        
        //let leftAxis:YAxis = graphView.leftAxis
        //leftAxis.drawAxisLineEnabled = false
        //leftAxis.drawGridLinesEnabled = false
        
        self.graphView.rightAxis.enabled = false
        
        let leftAxis:YAxis = self.graphView.leftAxis
        leftAxis.labelTextColor = UIColor.white
        
        let limitLine = ChartLimitLine(limit: 0, label: "")
        limitLine.lineColor = UIColor.black.withAlphaComponent(0.3)
        limitLine.lineWidth = 1
        self.graphView.rightAxis.addLimitLine(limitLine)
        
        loadActivityLog()
        
        tableView.dataSource = self
        tableView.delegate = self
    
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated) // No need for semicolon
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadActivityLog()
        tableView.reloadData()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setChart(dataPoints: [String], values: [Double]) {
        
        var dataEntries: [BarChartDataEntry] = Array()
        
        graphView.noDataText = "Loading Graph ....."
        
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(x: Double(i), yValues: [values[i]])
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(values: dataEntries, label: activity_name)
        let chartData = BarChartData(dataSet: chartDataSet)
        chartDataSet.barBorderWidth = 0.1
        chartDataSet.barShadowColor = UIColor(red:0.19, green:0.42, blue:0.91, alpha:1.0)
        chartDataSet.colors = [UIColor(red:0.19, green:0.42, blue:0.91, alpha:1.0)]
        
        graphView.xAxis.valueFormatter = IndexAxisValueFormatter(values:months)
        graphView.xAxis.granularity = 1
        graphView.setYAxisMinWidth(YAxis.AxisDependency(rawValue: 1)!, width: 1)
        graphView.data = chartData
        graphView.xAxis.labelPosition = .bottom
        graphView.rightAxis.enabled = false
        graphView.data?.setDrawValues(false)
    }
    
    func loadGraph() {
        self.fetchBarChartData(activityLog: self.activitiesLogAll[self.activity_name] ?? [])
        
        if self.durationForCharts.count == 0 || self.durationForCharts.count == 1 {
            self.durationForCharts = [0.0,0.0,0.0,0.0,0.0,0.0,0,0]
        } else {
            self.yAxisCount = self.durationForCharts
        }
        self.setChart(dataPoints: self.months, values: self.durationForCharts)
    }
    
    
    func loadActivityLog() {
        NSLog("Activity log request fired")
        self.activitiesLogAll.removeAll()
        ParseClient.sharedInstance.getActivities() { (activities: [Activity]?, error: Error?) -> Void in
            if error != nil {
                NSLog("Error getting activities from Parse")
            } else {
                NSLog("getActivities from Parse")
                self.activities = activities!
                
                if self.activities.count != 0 {
                    self.activity_name = self.activities[0].activityName!
                }
                
                ParseClient.sharedInstance.getActivityLog() { (activities: [ActivityLog]?, error: Error?) -> Void in
                    if error != nil {
                        NSLog("Error getting activities from Parse")
                    } else {
                        for activity in activities! {
                            var activityLogs = self.activitiesLogAll[activity.activity_name!] ?? []
                            activityLogs.append(activity)
                            self.activitiesLogAll[activity.activity_name!] = activityLogs
                            
                        }
                        //NSLog("Items from Parse for getTodayCountForActivity \(self.activitiesLogAll)")
                        
                        NSLog("Activity log request finished")
                        
                        self.fetchBarChartData(activityLog: self.activitiesLogAll[self.activity_name] ?? [])
                        
                        if self.durationForCharts.count == 0 || self.durationForCharts.count == 1 {
                            self.durationForCharts = [0.0,0.0,0.0,0.0,0.0,0.0,0,0]
                        } else {
                            self.yAxisCount = self.durationForCharts
                        }
                        self.setChart(dataPoints: self.months, values: self.durationForCharts)
                    }
                }
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
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
    
    func fetchBarChartData(activityLog: [ActivityLog]?) {
        var dates = getPastDates(days: 7)
        
        self.durationForCharts.removeAll()
        
        if(activityLog == nil || activityLog?.count == 0) {
            self.durationForCharts.append(0)
            print("no data found")
        } else {
            var counter = 0
            for x in dates {
                
                var totalCount: Int64 = 0
                for log in activityLog! {
                    if (log.activity_duration != nil && log.activity_event_date == String(describing: x)) {
                        totalCount += Int64(log.activity_duration!)
                    }
                }
                
                self.durationForCharts.append(Double(totalCount))
            }
        }

        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
        
    }
}

extension ReportGraphViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activities.count
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityReportCell", for: indexPath) as! ActivityReportCell
        cell.backgroundColor = UIColor(red: 9/255, green: 37/255, blue: 62/255, alpha: 1.0)
        let colorArray = [UIColor.cyan, UIColor.yellow, UIColor.orange, UIColor.green, UIColor.red]
        let randomIndex = Int(arc4random_uniform(UInt32(colorArray.count)))
        let activity = activities[indexPath.row]
        let pfImage = activity.activityImageFile
        if let imageFile : PFFile = pfImage{
            imageFile.getDataInBackground(block: { (data, error) in
                if error == nil {
                    let image = UIImage(data: data!)
                    cell.activityImageView.image = image
                    cell.activityImageView?.backgroundColor = colorArray[randomIndex]
                    
                } else {
                    print(error!.localizedDescription)
                }
            })
        }
        cell.activityNameLabel.text = activity.activityName
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
        return 120
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("indexPath clicked is \(activities[indexPath.row].activityName)")
        //self.durationForCharts = [Double]()
        let activity = activities[indexPath.row]
        //let activityLog = activitiesLogAll[activity.activityName!]
        self.activity_name = activity.activityName!
        loadGraph()
    }
    
    
}
