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
        self.navigationItem.title = "Goal Setting"
        
        activityNameLabel.text = self.activityName
        
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
        
        //Check if goal exist, then update or else add anew goal.
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
                    NSLog("Items from Parse")
                }
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




    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
