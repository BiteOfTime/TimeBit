//
//  DetailActivityViewController.swift
//  TimeBit
//
//  Created by Namrata Mehta on 4/29/17.
//  Copyright © 2017 BiteOfTime. All rights reserved.
//

import UIKit
@objc protocol DetailActivityViewControllerDelegate {
    @objc optional func detailActivityViewController(stopActivityDetails: Dictionary<String, Any>)
    @objc optional func detailActivityViewController(startActivityName: String)
}

class DetailActivityViewController: UIViewController, DetailActivity4CellDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var isTimerOn: Int!
    var anyActivityRunning: Bool!
    var activityRunning: String!
    var currentTimeOnTimer: String!
    var currentHour: Int!
    var currentMinute: Int!
    var currentSec: Int!
    var trackPassedSecond: Int64 = 0
    var activityStartTimeFromHomeScreen: Date!
    
    var detailActivity1Cell: DetailActivity1Cell!
    var delegate: DetailActivityViewControllerDelegate?
    // Expecting this value from the calling screen.
    var activity_name: String!
    var activityToday: [ActivityLog]!
    var today_Count: String?
    var tillDate_Count: String?
    var weekly_count: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hidesBottomBarWhenPushed = false
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.navigationItem.title = activity_name
        navigationController?.navigationBar.layer.shadowOffset = CGSize(width:0, height: 0)
        navigationController?.navigationBar.layer.shadowRadius = 3
        navigationController?.navigationBar.layer.shadowColor = UIColor.black.cgColor
        navigationController?.navigationBar.layer.shadowOpacity = 0.8
                
        tableView.register(UINib(nibName: "DetailActivity1Cell", bundle: nil), forCellReuseIdentifier: "DetailActivity1Cell")
        tableView.register(UINib(nibName: "DetailActivity2Cell", bundle: nil), forCellReuseIdentifier: "DetailActivity2Cell")
        tableView.register(UINib(nibName: "DetailActivity3Cell", bundle: nil), forCellReuseIdentifier: "DetailActivity3Cell")
        tableView.register(UINib(nibName: "DetailActivity4Cell", bundle: nil), forCellReuseIdentifier: "DetailActivity4Cell")
        
        loadLogForActivity()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200
        
        tableView.layer.borderWidth = 0.4
        tableView.layer.borderColor = UIColor(red:0.18, green:0.23, blue:0.29, alpha:1.0).cgColor
        
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func detailActivity4Cell(stopActivityDetails: Dictionary<String, Any>) {
        anyActivityRunning = false
        isTimerOn = -1
        loadLogForActivity()
        tableView.reloadData()
        delegate?.detailActivityViewController?(stopActivityDetails: stopActivityDetails)
    }
    
    func detailActivity4Cell(startActivityName: String) {
        delegate?.detailActivityViewController?(startActivityName: startActivityName)
    }
    
    func detailActivity4Cell(alertForAlreadyRunning: Bool, currentActivity: String) {
        let alert = UIAlertController(title: "TimeBit",
                                      message: "'\(activityRunning.capitalized)' already running. Stop '\(activityRunning.capitalized)' to start '\(currentActivity)'",
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: { (action) -> Void in
            print("OK")
        })
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    func loadLogForActivity() {
        let params = ["activity_name": activity_name] as [String : Any]
        
        ParseClient.sharedInstance.getTotalCountForActivity(params: params as NSDictionary?) { (activities: [ActivityLog]?, error: Error?) -> Void in
            if error != nil {
                NSLog("Error getting activities from Parse")
            } else {
                self.activityToday = activities!
                NSLog("Items from Parse \(self.activityToday)")
            }
            
            self.today_Count = ActivityLog.getTimeSpentToday(activityLog: self.activityToday)
            self.weekly_count = ActivityLog.getTimeSpentPastSevenDay(activityLog: activities )
            self.tillDate_Count = ActivityLog.getTimeSpentTillNow(activityLog: activities)
            
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
            })
        }
    }
    
}

extension DetailActivityViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailActivity1Cell", for: indexPath) as! DetailActivity1Cell
            
            cell.todayView?.layer.cornerRadius = 0.5 * (cell.todayView?.bounds.size.width)!
            cell.todayView?.layer.borderWidth = 3
            cell.todayView?.layer.borderColor = UIColor(red:0.23, green:0.52, blue:0.96, alpha:1.0).cgColor
            cell.todayView?.layer.shadowOpacity = 1.0
            cell.todayView?.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
            cell.todayView?.layer.shadowRadius = 10
            cell.todayView?.layer.shadowColor = UIColor(red: 2/255, green: 11/255, blue: 23/255, alpha: 1.0).cgColor
            
            cell.weeklyView?.layer.cornerRadius = 0.5 * (cell.weeklyView?.bounds.size.width)!
            cell.weeklyView?.layer.borderWidth = 3
            cell.weeklyView?.layer.borderColor = UIColor(red: 242/255, green: 108/255, blue: 79/255, alpha: 1.0).cgColor
            cell.weeklyView?.layer.shadowOpacity = 1.0
            cell.weeklyView?.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
            cell.weeklyView?.layer.shadowRadius = 10
            cell.weeklyView?.layer.shadowColor = UIColor(red: 2/255, green: 11/255, blue: 23/255, alpha: 1.0).cgColor
            
            cell.tillDateView?.layer.cornerRadius = 0.5 * (cell.tillDateView?.bounds.size.width)!
            cell.tillDateView?.layer.borderWidth = 3
            cell.tillDateView?.layer.borderColor = UIColor(red:0.51, green:0.94, blue:0.71, alpha:1.0).cgColor
            cell.tillDateView?.layer.shadowOpacity = 1.0
            cell.tillDateView?.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
            cell.tillDateView?.layer.shadowRadius = 10
            cell.tillDateView?.layer.shadowColor = UIColor(red: 2/255, green: 11/255, blue: 23/255, alpha: 1.0).cgColor
            cell.layer.borderColor = CustomUIFunctions.getlineColor()
            cell.layer.borderWidth = CustomUIFunctions.getlineWidth()
            
            var todayCountArr = today_Count?.components(separatedBy: " ")
            cell.dailyCount?.text = todayCountArr?.first
            cell.todayTimeLabel?.text = todayCountArr?.last
            var weeklyCountArr = weekly_count?.components(separatedBy: " ")
            cell.weeklyCount?.text = weeklyCountArr?.first
            cell.weekTimeLabel.text = weeklyCountArr?.last
            var sinceCreationCountArr = tillDate_Count?.components(separatedBy: " ")
            cell.sinceCreationCount?.text = sinceCreationCountArr?.first
            cell.sinceCreationTimeLabel.text = sinceCreationCountArr?.last
            
            cell.selectionStyle = .none
            
            return cell
        }
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailActivity2Cell", for: indexPath) as! DetailActivity2Cell
            
            cell.layer.shadowColor = UIColor(red: 2/255, green: 11/255, blue: 23/255, alpha: 1.0).cgColor
            cell.layer.shadowOpacity = 1.0
            cell.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
            cell.layer.borderColor = CustomUIFunctions.getlineColor()
            cell.layer.borderWidth = CustomUIFunctions.getlineWidth()
            
            cell.selectionStyle = .none
            
            return cell
        }
        if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailActivity3Cell", for: indexPath) as! DetailActivity3Cell
            
            cell.layer.shadowColor = UIColor(red: 2/255, green: 11/255, blue: 23/255, alpha: 1.0).cgColor
            cell.layer.shadowOpacity = 1.0
            cell.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
            cell.layer.borderColor = CustomUIFunctions.getlineColor()
            cell.layer.borderWidth = CustomUIFunctions.getlineWidth()
            
            cell.selectionStyle = .none
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailActivity4Cell", for: indexPath) as! DetailActivity4Cell
            cell.selectionStyle = .none
            cell.startButton.layer.cornerRadius = 16.0
            cell.delegate = self
            cell.activity_name = activity_name
            cell.isTimerOn = isTimerOn

            if anyActivityRunning && isTimerOn == -1 {
                print("disabling start button")
                cell.anyActivityRunning = true
                //cell.startButton.isEnabled = false
            } else {
                cell.startButton.isEnabled = true
                print("value of isTimerOn in home screen is \(isTimerOn)")
                if isTimerOn != -1 {
                    print("Timer is started at the home screen for activity \(activity_name) and time is \(currentTimeOnTimer)")
                    cell.hourLabel.text = currentHour > 9 ? "\(currentHour!)" : "0\(currentHour!)"
                    cell.minuteLabel.text = currentHour > 9 ? "\(currentMinute!)" : "0\(currentMinute!)"
                    cell.secondLabel.text = currentSec > 9 ? "\(currentSec!)" : "0\(currentSec!)"
                    
                    //cell.startButton.setTitle("Stop", for: UIControlState())
                    cell.startButton.isSelected = true
                    cell.startDate = self.activityStartTimeFromHomeScreen
                    cell.startNewTimer = false
                    //cell.startActivity = !cell.startActivity
                    cell.passedSeconds = Int64(self.currentSec) + 60*Int64(self.currentMinute) + 3600*Int64(self.currentHour)
                    cell.invalidateTimer()
                    cell.startActivityTimer()
                } else {
                    // Marking cell.startActivity to !cell.startActivity in start button click 
                    cell.startActivity = false
                    cell.startNewTimer = true
                    print("No timer started for this activity")
                }
            }
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
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            navigationController?.pushViewController(gvc, animated: true)
        } else if indexPath.section == 2 {
            print("Share with friends")
            let gvc = ReportViewController(nibName: "ReportViewController", bundle: nil)
            gvc.activity_name = activity_name
            gvc.activityLog = activityToday
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            navigationController?.pushViewController(gvc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        if indexPath.section == 0 {
            return 150
        }
        else if indexPath.section == 1 {
            return 55
        }
        else if indexPath.section == 2 {
            return 55
        }
        else if indexPath.section == 3 {
            return 320
        }
        return 10
    }
    
    
}
