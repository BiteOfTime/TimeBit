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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Connect data:
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        //set Navigation bar title and color
        self.tabBarController?.navigationItem.title = "Goals"
        self.navigationItem.title = "Goals"
        
//        let UserId = activity.user_id
  //      let activityName = activity.activity_name
 //       activityNameLabel.text = activityName
        let goalSetting = self.goalSetting
        activityNameLabel.text = self.activityName
        
        // Input data into the PickerArray:
        PickerData = [["Atleast", "Atmax", "Exactly"],
                      ["0hr", "1hr", "2hr", "3hr", "4hr", "5hr", "6hr", "7hr", "8hr", "9hr", "10hr", "11hr", "12hr", "13hr", "14hr", "15hr", "16hr", "17hr", "18hr", "19hr", "20hr", "21hr", "22hr", "23hr", "24hr"],
                      ["00min", "05min", "10min", "15min", "20min", "25min", "30min", "35min", "40min", "45min", "50min", "55min", "60min"],
                      ["Today", "Daily", "Weekly"]]
        
        if goalSetting == "Update" {
            saveGoalButton.setTitle("Update", for: .normal)
        }
        
        ParseClient.sharedInstance.getActivityGoals(activityName: activityName as String?) { (goals: [Goal]?, error: Error?) -> Void in
            if error != nil {
                NSLog("Error getting goals from Parse")
            } else {
                self.goal = goals![0]
                print(self.goal)
                let hrs = self.goal.hours
                let mins = self.goal.mins
                print(hrs, mins)
                let goalHrs = "\(hrs ?? 0)" + "hr "
                let goalMins = "\(mins ?? 0)" + "min "
                let currentGoal = self.goal.limit! + " " + goalHrs + goalMins + self.goal.frequency!
                
                //let currentGoal = ("\(self.goal.limit) \(self.goal.hours)hr \(self.goal.mins)mins \(self.goal.frequency)")
                self.currentGoalLabel.text = currentGoal
                NSLog("Items from Parse")
            }
        }
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
        
        print(limit)
        print(hours)
        print(mins)
        print(frequency)
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
        if goalSetting == "Save" {
            ParseClient.sharedInstance.saveNewGoal(params: params as NSDictionary?) { (PFObject, Error)      -> () in
                if Error != nil {
                    NSLog("Error saving to Parse")
                } else {
                    NSLog("Saved activity goal to Parse")
                }
            }
        } else {
            ParseClient.sharedInstance.updateGoal(params: params as NSDictionary?, completion: { (PFObject, Error) -> () in
                if Error != nil {
                    NSLog("Error updating goal to Parse")
                } else {
                    NSLog("Updated activity goal to Parse")
                }
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
