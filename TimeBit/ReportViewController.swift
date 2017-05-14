//
//  ReportViewController.swift
//  TimeBit
//
//  Created by Krishna Alex on 4/29/17.
//  Copyright © 2017 BiteOfTime. All rights reserved.
//

import UIKit
import Charts
import Parse
import ParseUI

class ReportViewController: UIViewController {

    
    @IBOutlet weak var graphView: BarChartView!
    
    var months: [String] = ["Wed", "Tue", "Mon", "Sun", "Sat", "Fri", "Thr"]
    var durationForCharts: [Double] = []
    var yAxisCount: [Double] = []
    var activity_name: String!
    var activityLog: [ActivityLog]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = activity_name
        self.months = ["Wed", "Tue", "Mon", "Sun", "Sat", "Fri", "Thr"]
        
        self.graphView.animate(yAxisDuration: 1.0)
        self.graphView.pinchZoomEnabled = false
        self.graphView.drawBarShadowEnabled = false
        self.graphView.drawBordersEnabled = false
        self.graphView.chartDescription?.text = ""
        
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
        
        loadGraph()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadGraph() {
        self.fetchBarChartData(activityLog: activityLog ?? [])
        
        if self.durationForCharts.count == 0 || self.durationForCharts.count == 1 {
            self.durationForCharts = [0.0,0.0,0.0,0.0,0.0,0.0,0,0]
        } else {
            self.yAxisCount = self.durationForCharts
        }
        self.setChart(dataPoints: self.months, values: self.durationForCharts)
    }
    
    func fetchBarChartData(activityLog: [ActivityLog]?) {
        var dates = ActivityLog.getPastDates(days: 7)
        
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
        
        chartDataSet.highlightColor = NSUIColor.white
        
        graphView.xAxis.valueFormatter = IndexAxisValueFormatter(values:months)
        graphView.xAxis.granularity = 1
        graphView.setYAxisMinWidth(YAxis.AxisDependency(rawValue: 1)!, width: 1)
        graphView.data = chartData
        graphView.xAxis.labelPosition = .bottom
        graphView.rightAxis.enabled = false
        graphView.data?.setDrawValues(false)
    }
}
