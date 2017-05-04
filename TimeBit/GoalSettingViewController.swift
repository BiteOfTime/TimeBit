//
//  GoalSettingViewController.swift
//  TimeBit
//
//  Created by Krishna Alex on 4/28/17.
//  Copyright © 2017 BiteOfTime. All rights reserved.
//

import UIKit
import Parse

class GoalSettingViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var activityNameLabel: UILabel!
    @IBOutlet var containerView: UIView!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var saveGoalButton: UIButton!
    @IBOutlet weak var currentGoalLabel: UILabel!
    @IBOutlet weak var goalCompletionPercentageLabel: UILabel!
    
    var PickerData: [[String]] = [[String]]()
    var activity: Activity!
    var activityName: String!
    var goalSetting: String!
    var limit: String!
    var hours: String!
    var mins: String!
    var frequency: String!
    var goal: Goal!
    var goals: [Goal]!
    var activityToday: [ActivityLog]!
    var today_Count: String?
    var countDuration: Int64 = 0
    var countDurationToday: Int64 = 0
    var countDurationWeekly: Int64 = 0
    var weekly_count: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Connect data:
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        //set Navigation bar title and color
        self.tabBarController?.navigationItem.title = "Goals"
        self.navigationItem.title = "Goal Setting"
        
        activityNameLabel.text = self.activityName
        self.goalCompletionPercentageLabel.text = "0"
        
        // Input data into the PickerArray:
        PickerData = [["Atleast", "Atmax", "Exactly"],
                      ["0hr", "1hr", "2hr", "3hr", "4hr", "5hr", "6hr", "7hr", "8hr", "9hr", "10hr", "11hr", "12hr", "13hr", "14hr", "15hr", "16hr", "17hr", "18hr", "19hr", "20hr", "21hr", "22hr", "23hr", "24hr"],
                      ["00min", "05min", "10min", "15min", "20min", "25min", "30min", "35min", "40min", "45min", "50min", "55min", "60min"],
                      ["Daily", "Weekly"]]
        pickerView.selectRow(1, inComponent: 0, animated: true)
        pickerView.selectRow(2, inComponent: 1, animated: true)
        pickerView.selectRow(2, inComponent: 2, animated: true)
        pickerView.selectRow(0, inComponent: 3, animated: true)
        limit = PickerData[0][pickerView.selectedRow(inComponent: 0)]
        let hoursString = PickerData[1][pickerView.selectedRow(inComponent: 1)]
        hours = String(hoursString.characters.dropLast(2))
        let minsString = PickerData[2][pickerView.selectedRow(inComponent: 2)]
        mins = String(minsString.characters.dropLast(3))
        frequency = PickerData[3][pickerView.selectedRow(inComponent: 3)]
        
        self.currentGoalLabel.text = "No goal set"
        
        //Check if goal exist, then update or else add a new goal.
        ParseClient.sharedInstance.getActivityGoals(activityName: self.activityName as String?) { (goal: Goal?, error: Error?) -> Void in
            if error != nil {
                NSLog("No current goals from Parse")
                self.goalSetting = "Save"
                self.saveGoalButton.setTitle("Save", for: .normal)
            } else {
                if let goalForActivity = goal {
                    self.goalSetting = "Update"
                    self.saveGoalButton.setTitle("Update", for: .normal)
                    self.goal = goalForActivity
                    let hrsString = "\(goalForActivity.hours!)" + "hr "
                    let minsString = "\(goalForActivity.mins!)" + "min "
                    let currentGoal = goalForActivity.limit! + " " + hrsString + minsString + goalForActivity.frequency!
                    self.currentGoalLabel.text = currentGoal
//                    print("hrs", goalForActivity.hours)
//                    print("mins", goalForActivity.mins)
//                    print("frequency", goalForActivity.frequency)
                    self.goalPercentageCompletion(goalFrequency: goalForActivity.frequency!, goalHours: goalForActivity.hours!, goalMins: goalForActivity.mins!)
//                    if goalForActivity.frequency == "Daily" {
//                        self.todayCount()
//                    } else {
//                        //self.weeklyCount()
//                    }
                    NSLog("Items from Parse")
                }
            }
        }
        
        //UIView *lineView = [[UIView alloc] initWithFrame,CGRectMake(0, 200, self.view.bounds.size.width, 1)];
//        let lineview = UIView.init(frame: CGRect(x: 0, y: 0, width: 480, height: 320))
//        lineview.backgroundColor = UIColor.gray
//        self.view.addSubview(lineview)
        //lineview.release
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 4
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return PickerData[component].count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return PickerData[component][row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        limit = PickerData[0][pickerView.selectedRow(inComponent: 0)]
        let hoursString = PickerData[1][pickerView.selectedRow(inComponent: 1)]
        hours = String(hoursString.characters.dropLast(2))
        let minsString = PickerData[2][pickerView.selectedRow(inComponent: 2)]
        mins = String(minsString.characters.dropLast(3))
        frequency = PickerData[3][pickerView.selectedRow(inComponent: 3)]
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
        pickerLabel?.text = PickerData[component][row]
        return pickerLabel!
    }
    
    
    @IBAction func onSaveUpdateButton(_ sender: Any) {
        let params = ["activityName": activityName!, "limit": limit!, "hours": hours!, "mins": mins, "frequency": frequency!] as [String : Any]
        print("params")
        print(params)
        if self.goalSetting == "Save" {
            ParseClient.sharedInstance.saveNewGoal(params: params as NSDictionary?) { (PFObject, Error) -> () in
                if Error != nil {
                    NSLog("Error saving to Parse")
                } else {
                    NSLog("Saved activity goal to Parse")
                }
            }
            self.navigationController?.popViewController(animated: true)
        } else {
            ParseClient.sharedInstance.updateGoal(params: params as NSDictionary?, completion: { (PFObject, Error) -> () in
                if Error != nil {
                    NSLog("Error updating goal to Parse")
                } else {
                    print("Updated activity goal to Parse")
                }
            })
            self.navigationController?.popViewController(animated: true)
        }
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
        today_Count = "0 sec"
        print("todayGoalPercentageCompletion")
        let currentDate = formatDate(dateString: String(describing: Date()))
        let params = ["activity_name": activityName!, "activity_event_date": currentDate] as [String : Any]
        
        ParseClient.sharedInstance.getTodayCountForActivity(params: params as NSDictionary?) { (activities: [ActivityLog]?, error: Error?) -> Void in
            if error != nil {
                NSLog("Error getting activities from Parse")
            } else {
                self.activityToday = activities!
                //NSLog("Items from Parse \(self.activityToday)")
                
                self.activityToday.forEach { x in
                    self.countDurationToday = self.countDurationToday + x.activity_duration!
                }
                print("self.countDurationToday ", self.countDurationToday )
                //let todayCountInSec = self.countDurationToday % 60
                var goalInSec: Int64 = 0
                if goalHours > 0 {
                    goalInSec += goalHours * 3600
                }
                if goalMins > 0 {
                    goalInSec += goalMins * 60
                }
                print("goalInSec", goalInSec)
                let percentageCompletion = Double(self.countDurationToday) / Double(goalInSec) * 100
                let completionPercentage = Double(percentageCompletion).roundTo(places: 2)
                print("percentageCompletion", percentageCompletion)

                self.goalCompletionPercentageLabel.text = "\(completionPercentage)%"

            }
        }
        
    }
    
    func weeklyGoalPercentageCompletion(goalHours: Int, goalMins: Int) {
        weekly_count = "0 sec"
        print("weeklyGoalPercentageCompletion")
        
        let params = ["activity_name": activityName!] as [String : Any]
        
        ParseClient.sharedInstance.getTotalCountForActivity(params: params as NSDictionary?) { (activities: [ActivityLog]?, error: Error?) -> Void in
            if error != nil {
                NSLog("Error getting activities from Parse")
            } else {
                self.activityToday = activities!
                NSLog("Items from Parse \(self.activityToday)")
                
                let weekDateRange = self.getPastDates(days: 7)
                
                self.activityToday.forEach { x in
                    if(weekDateRange.contains(x.activity_event_date)) {
                        self.countDurationWeekly = self.countDurationWeekly + x.activity_duration!
                    }
                }
                //self.weekly_count = self.calculateCount(duration: self.countDurationWeekly)
                var goalInSec: Int64 = 0
                if goalHours > 0 {
                    goalInSec += goalHours * 3600
                }
                if goalMins > 0 {
                    goalInSec += goalMins * 60
                }
                print("self.countDurationWeekly", self.countDurationWeekly)
                print("goalInSec", goalInSec)
                let percentageCompletion = Double(self.countDurationWeekly) / Double(goalInSec) * 100
                let completionPercentage = Double(percentageCompletion).roundTo(places: 2)
                print("percentageCompletion", String(format:"%.2f", percentageCompletion))
                print(String(format: "%.2f", percentageCompletion))
                
                self.goalCompletionPercentageLabel.text = "\(completionPercentage)%"
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
