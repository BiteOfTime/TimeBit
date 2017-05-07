//
//  GoalSettingViewController.swift
//  TimeBit
//
//  Created by Krishna Alex on 4/28/17.
//  Copyright © 2017 BiteOfTime. All rights reserved.
//

import UIKit
import Parse
import CircleProgressView
import UserNotifications
import UserNotificationsUI

class GoalSettingViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var activityNameLabel: UILabel!
    @IBOutlet var containerView: UIView!
    @IBOutlet weak var goalpickerView: UIPickerView!
    @IBOutlet weak var saveGoalButton: UIButton!
    @IBOutlet weak var currentGoalLabel: UILabel!
    @IBOutlet weak var goalCompletionPercentageLabel: UILabel!
    @IBOutlet weak var progrssViewContainer: UIView!
    @IBOutlet weak var datePickerView: UIPickerView!
    var progressview: CircleProgressView!
    @IBOutlet weak var notifyButton: UIButton!
    
    var PickerData: [[String]] = [[String]]()
    var DatePickerData: [[String]] = [[String]]()
    var DailyDatePickerData: [[String]] = [[String]]()
    var activity: Activity!
    var activityName: String!
    var goalSetting: String!
    var limit: String!
    var hours: String!
    var mins: String!
    var frequency: String!
    var goalFrequency: String!
    var goalLimit: String!
    var goalHrs: Int!
    var goalMins: Int!
    var goal: Goal!
    var goals: [Goal]!
    var activityLog: [ActivityLog]!
    var countDuration: Int64 = 0
    var countDurationToday: Int64 = 0
    var countDurationWeekly: Int64 = 0
    var requestIdentifier: String!
    
    var notificationHour:String!
    var notificationMin:String!
    var notificationAMPM:String!
    var notificationWeekday:String!
    let weekdayDictionary = ["Sun" : 1, "Mon": 2, "Tue": 3, "Wed": 4, "Thu": 5, "Fri": 6, "Sat": 7]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set Navigation bar title and color
        self.tabBarController?.navigationItem.title = "Goals"
        self.navigationItem.title = "Goal Setting"
        
        activityNameLabel.text = self.activityName
        self.goalCompletionPercentageLabel.text = "0%"
        
        //Check if goal exist, then update or else add a new goal.
        getCurrentGoal()
        DispatchQueue.main.async(execute: {
            self.goalFrequency = "Daily"
            self.datePickerView.isHidden = true
        
            // Connect data:
            self.goalpickerView.delegate = self
            self.goalpickerView.dataSource = self
            self.datePickerView.delegate = self
            self.datePickerView.dataSource = self
            
            // Input data into the PickerArray:
            self.PickerData = [["Atleast", "Atmax", "Exactly"],
                      ["0hr", "1hr", "2hr", "3hr", "4hr", "5hr", "6hr", "7hr", "8hr", "9hr", "10hr", "11hr", "12hr", "13hr", "14hr", "15hr", "16hr", "17hr", "18hr", "19hr", "20hr", "21hr", "22hr", "23hr", "24hr"],
                      ["00min", "05min", "10min", "15min", "20min", "25min", "30min", "35min", "40min", "45min", "50min", "55min"],
                      ["Daily", "Weekly"]]
            self.DatePickerData = [["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"],
                      ["00", "05", "10", "15", "20", "25", "30", "35", "40", "45", "50", "55"],
                      ["AM", "PM"],
                      ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]]
            self.DailyDatePickerData = [["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"],
                          ["00", "05", "10", "15", "20", "25", "30", "35", "40", "45", "50", "55"],
                          ["AM", "PM"]]
        
            self.goalpickerView.selectRow(1, inComponent: 0, animated: true)
            self.goalpickerView.selectRow(2, inComponent: 1, animated: true)
            self.goalpickerView.selectRow(2, inComponent: 2, animated: true)
            self.goalpickerView.selectRow(0, inComponent: 3, animated: true)
            self.limit = self.PickerData[0][self.goalpickerView.selectedRow(inComponent: 0)]
            let hoursString = self.PickerData[1][self.goalpickerView.selectedRow(inComponent: 1)]
            self.hours = String(hoursString.characters.dropLast(2))
            let minsString = self.PickerData[2][self.goalpickerView.selectedRow(inComponent: 2)]
            self.mins = String(minsString.characters.dropLast(3))
            self.frequency = self.PickerData[3][self.goalpickerView.selectedRow(inComponent: 3)]
            
            self.datePickerView.selectRow(1, inComponent: 0, animated: true)
            self.datePickerView.selectRow(2, inComponent: 1, animated: true)
            self.datePickerView.selectRow(2, inComponent: 2, animated: true)
            print("goalFrequency in main", self.goalFrequency)
            if self.goalFrequency == "Weekly" {
                self.datePickerView.selectRow(0, inComponent: 3, animated: true)
                self.notificationHour = self.DatePickerData[0][self.datePickerView.selectedRow(inComponent: 0)]
                self.notificationMin = self.DatePickerData[1][self.datePickerView.selectedRow(inComponent: 1)]
                self.notificationAMPM = self.DatePickerData[2][self.datePickerView.selectedRow(inComponent: 2)]
                self.notificationWeekday = self.DatePickerData[3][self.datePickerView.selectedRow(inComponent: 3)]
            } else {
                self.notificationHour = self.DailyDatePickerData[0][self.datePickerView.selectedRow(inComponent: 0)]
                self.notificationMin = self.DailyDatePickerData[1][self.datePickerView.selectedRow(inComponent: 1)]
                self.notificationAMPM = self.DailyDatePickerData[2][self.datePickerView.selectedRow(inComponent: 2)]
            }
            
            self.datePickerView.reloadAllComponents()
        
            self.currentGoalLabel.text = "No goal set"
            self.requestIdentifier = self.activityName
        
        })
        
        //Add a circular progress view to track goal completion percentage
        progressview = CircleProgressView(frame: CGRect(x: 0, y: 0, width: 85, height: 85))
        progressview.clockwise = true
        progressview.centerFillColor = UIColor(displayP3Red: 0.05, green: 0.33, blue: 0.49, alpha: 1.0)
        progressview.trackBackgroundColor = UIColor(displayP3Red: 0.05, green: 0.33, blue: 0.49, alpha: 1.0)
        progressview.backgroundColor = UIColor(displayP3Red: 0.04, green: 0.17, blue: 0.27, alpha: 1.0)
        progressview.trackBorderColor = .blue
        self.progrssViewContainer.addSubview(progressview)
        self.progressview.addSubview(goalCompletionPercentageLabel)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getCurrentGoal() {
        //Check if goal exist, then update or else add a new goal.
        ParseClient.sharedInstance.getActivityGoals(activityName: self.activityName as String?) { (goal: Goal?, error: Error?) -> Void in
            if error != nil {
                NSLog("No current goals from Parse")
                self.goalSetting = "Save"
                self.saveGoalButton.setTitle("Save", for: .normal)
                self.notifyButton.isEnabled = false
            } else {
                if let goalForActivity = goal {
                    self.goalSetting = "Update"
                    self.notifyButton.isEnabled = true
                    self.saveGoalButton.setTitle("Update", for: .normal)
                    self.goal = goalForActivity
                    self.goalFrequency = goalForActivity.frequency!
                    self.goalLimit = goalForActivity.limit!
                    self.goalHrs = goalForActivity.hours!
                    self.goalMins = goalForActivity.mins!
                    let hrsString = "\(goalForActivity.hours!)" + "hr "
                    let minsString = "\(goalForActivity.mins!)" + "min "
                    let currentGoal = goalForActivity.limit! + " " + hrsString + minsString + goalForActivity.frequency!
                    self.currentGoalLabel.text = currentGoal
                    self.goalPercentageCompletion(goalFrequency: goalForActivity.frequency!, goalHours: goalForActivity.hours!, goalMins: goalForActivity.mins!)
                }
            }
        }

    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        print("frequency inside pickerView", goalFrequency)
        if pickerView == datePickerView {
            if goalFrequency == "Weekly" {
                return 4
            } else {
                return 3
            }
        } else {
            return 4
        }
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == datePickerView {
            if goalFrequency == "Weekly" {
                return DatePickerData[component].count
            } else {
                return DailyDatePickerData[component].count
            }
        } else {
            return PickerData[component].count
        }
    }

    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == datePickerView {
            if goalFrequency == "Weekly" {
                return DatePickerData[component][row]
            } else {
                return DailyDatePickerData[component][row]
            }
        } else {
            return PickerData[component][row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == datePickerView {
            if goalFrequency == "Weekly" {
                notificationHour = DatePickerData[0][pickerView.selectedRow(inComponent: 0)]
                notificationMin = DatePickerData[1][pickerView.selectedRow(inComponent: 1)]
                notificationAMPM = DatePickerData[2][pickerView.selectedRow(inComponent: 2)]
                notificationWeekday = DatePickerData[3][pickerView.selectedRow(inComponent: 3)]
            } else {
                notificationHour = DailyDatePickerData[0][pickerView.selectedRow(inComponent: 0)]
                notificationMin = DailyDatePickerData[1][pickerView.selectedRow(inComponent: 1)]
                notificationAMPM = DailyDatePickerData[2][pickerView.selectedRow(inComponent: 2)]
            }
        } else {
            limit = PickerData[0][pickerView.selectedRow(inComponent: 0)]
            let hoursString = PickerData[1][pickerView.selectedRow(inComponent: 1)]
            hours = String(hoursString.characters.dropLast(2))
            let minsString = PickerData[2][pickerView.selectedRow(inComponent: 2)]
            mins = String(minsString.characters.dropLast(3))
            frequency = PickerData[3][pickerView.selectedRow(inComponent: 3)]
        }
    }
    
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var pickerLabel = view as? UILabel;
        
        if (pickerLabel == nil)
        {
            pickerLabel = UILabel()
            
            pickerLabel?.font = UIFont(name: "Avenir Next", size: 16)
            pickerLabel?.textAlignment = NSTextAlignment.center
            pickerLabel?.textColor = .white
        }
        if pickerView == datePickerView {
            pickerLabel?.text = DatePickerData[component][row]
        } else {
            pickerLabel?.text = PickerData[component][row]
        }
        return pickerLabel!

    }
    
    
    @IBAction func onSaveUpdateButton(_ sender: Any) {
        let params = ["activityName": activityName!, "limit": limit!, "hours": hours!, "mins": mins, "frequency": frequency!] as [String : Any]
        print("params")
        print(params)
        self.notifyButton.isEnabled = true
        if self.goalSetting == "Save" {
            ParseClient.sharedInstance.saveNewGoal(params: params as NSDictionary?) { (PFObject, Error) -> () in
                if Error != nil {
                    NSLog("Error saving to Parse")
                } else {
                    NSLog("Saved activity goal to Parse")
                    //self.goalFrequency = self.frequency!
                }
            }
        } else {
            ParseClient.sharedInstance.updateGoal(params: params as NSDictionary?, completion: { (PFObject, Error) -> () in
                if Error != nil {
                    NSLog("Error updating goal to Parse")
                } else {
                    print("Updated activity goal to Parse")
                }
            })
        }
        self.goalFrequency = frequency!
        self.goalLimit = limit!
        self.goalHrs = Int(hours)!
        self.goalMins = Int(mins)!
        let hrsString = "\(hours!)" + "hr "
        let minsString = "\(mins!)" + "min "
        let currentGoal = limit! + " " + hrsString + minsString + frequency!
        self.currentGoalLabel.text = currentGoal
    }
    
    
    func goalPercentageCompletion(goalFrequency: String, goalHours: Int, goalMins: Int) {
        print("goalPercentageCompletion")
        print("frequency", goalFrequency)
        print("hours", goalHours)
        print("mins", goalMins)
        if goalFrequency == "Daily" {
            todayGoalPercentageCompletion(goalHours: goalHours, goalMins: goalMins)
            print("Daily Goal")
        } else if goalFrequency == "Weekly" {
            weeklyGoalPercentageCompletion(goalHours: goalHours, goalMins: goalMins)
            print("Weekly Goal")
        }
        
    }
    
    func todayGoalPercentageCompletion(goalHours: Int, goalMins: Int){
        let currentDate = formatDate(dateString: String(describing: Date()))
        let params = ["activity_name": activityName!, "activity_event_date": currentDate] as [String : Any]
        
        ParseClient.sharedInstance.getTodayCountForActivity(params: params as NSDictionary?) { (activities: [ActivityLog]?, error: Error?) -> Void in
            if error != nil {
                NSLog("Error getting activities from Parse")
            } else {
                self.activityLog = activities!
                self.activityLog.forEach { x in
                    self.countDurationToday = self.countDurationToday + x.activity_duration!
                }
                var goalInSec: Int64 = 0
                if goalHours > 0 {
                    goalInSec += goalHours * 3600
                }
                if goalMins > 0 {
                    goalInSec += goalMins * 60
                }
                let percentageCompletion = Double(self.countDurationToday) / Double(goalInSec) * 100
                let completionPercentage = Double(percentageCompletion).roundTo(places: 1)
                self.goalCompletionPercentageLabel.text = "\(completionPercentage)%"

                let completion = completionPercentage / 100
                self.progressview.setProgress(completion, animated: true)
            }
        }
        
    }
    
    func weeklyGoalPercentageCompletion(goalHours: Int, goalMins: Int) {
        let params = ["activity_name": activityName!] as [String : Any]
        
        ParseClient.sharedInstance.getTotalCountForActivity(params: params as NSDictionary?) { (activities: [ActivityLog]?, error: Error?) -> Void in
            if error != nil {
                NSLog("Error getting activities from Parse")
            } else {
                self.activityLog = activities!
                let weekDateRange = self.getPastDates(days: 7)
                self.activityLog.forEach { x in
                    if(weekDateRange.contains(x.activity_event_date)) {
                        self.countDurationWeekly = self.countDurationWeekly + x.activity_duration!
                    }
                }
                var goalInSec: Int64 = 0
                if goalHours > 0 {
                    goalInSec += goalHours * 3600
                }
                if goalMins > 0 {
                    goalInSec += goalMins * 60
                }
                let percentageCompletion = Double(self.countDurationWeekly) / Double(goalInSec) * 100
                let completionPercentage = Double(percentageCompletion).roundTo(places: 1)
                print(String(format: "%.2f", percentageCompletion))
                
                self.goalCompletionPercentageLabel.text = "\(completionPercentage)%"
                let completion = completionPercentage / 100
                self.progressview.setProgress(completion, animated: true)
            }
            

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
    
    @IBAction func onDeleteGoalButton(_ sender: Any) {
        let params = ["activityName": activityName!] as [String : Any]
        ParseClient.sharedInstance.deleteGoal(params: params as NSDictionary?, completion: { (PFObject, Error) -> () in
            if Error != nil {
                NSLog("Error deleting goal from Parse")
            } else {
                print("Deleted activity goal from Parse")
            }
        })
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func setNotification() {
        print("activityName", activityName)
        print("requestIdentifier", requestIdentifier)
        print("notification will be triggered")
        let content = UNMutableNotificationContent()
        content.title = "Its time for \(activityName!)"
        //content.subtitle = "\(activityName) Activity Goal"
        let hrsString = "\(goalHrs!)" + "hr "
        let minsString = "\(goalMins!)" + "min "
        content.body = "Your goal is \(goalLimit!) \(hrsString)\(minsString)\(goalFrequency!)"
        content.sound = UNNotificationSound.default()
        content.setValue(true, forKeyPath: "shouldAlwaysAlertWhileAppIsForeground")
        
        // Deliver the notification at the specified time.
        var dateComponents = DateComponents()
        dateComponents.hour = Int(notificationHour)
        dateComponents.minute = Int(notificationMin)
        if goalFrequency == "Weekly" {
            dateComponents.weekday = weekdayDictionary[notificationWeekday]
        }
        print("date components")
        print(dateComponents.hour)
        print(dateComponents.minute)
        print(dateComponents.weekday)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
       // let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 5.0, repeats: false)
        let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
        
        //Schedule the notification
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.add(request)
        
        center.getPendingNotificationRequests { (notifications) in
            print("Count: \(notifications.count)")
            for item in notifications {
                print(item.content)
                print(item.content.body)
                print(item.content.title)
                print(item.content.subtitle)
            }
        }
    }
    
    @IBAction func onDeleteNotification(_ sender: Any) {
        
        print("Removed all pending notifications")
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [requestIdentifier])
    }
    
    @IBAction func onNotifyMe(_ sender: Any) {
        datePickerView.reloadAllComponents()
        if datePickerView.isHidden {
            animateMyViews(viewToHide: goalpickerView, viewToShow: datePickerView)
        }
        else{
            animateMyViews(viewToHide: datePickerView, viewToShow: goalpickerView)
            setNotification()
        }
        
        saveGoalButton.isEnabled = !saveGoalButton.isEnabled
        
    }
    
    func animateMyViews(viewToHide: UIView, viewToShow: UIView) {
        let animationDuration = 0.35
        
        UIView.animate(withDuration: animationDuration, animations: { () -> Void in
            viewToHide.transform = viewToHide.transform.scaledBy(x: 0.001, y: 0.001)
        }) { (completion) -> Void in
            
            viewToHide.isHidden = true
            viewToShow.isHidden = false
            
            viewToShow.transform = viewToShow.transform.scaledBy(x: 0.001, y: 0.001)
            
            //UIView.animateWithDuration(withDuration: animationDuration, animations: { () -> Void in
            UIView.animate(withDuration: animationDuration, animations: { () -> Void in
                viewToShow.transform = CGAffineTransform.identity
            })
        }
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension Double {
    /// Rounds the double to decimal places value
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension GoalSettingViewController: UNUserNotificationCenterDelegate {
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        print("Tapped in notification")
    }
    
    //This is key callback to present notification while the app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        print("Notification being triggered")
        //You can either present alert ,sound or increase badge while the app is in foreground too with ios 10
        //to distinguish between notifications
        if notification.request.identifier == requestIdentifier{
            
            completionHandler( [.alert,.sound,.badge])
            
        }
    }
}

