//
//  DemoViewController.swift
//  TimeBit
//
//  Created by Krishna Alex on 4/29/17.
//  Copyright © 2017 BiteOfTime. All rights reserved.
//

import UIKit

class DemoViewController: UIViewController {
    
    @IBOutlet weak var newActivityText: UITextField!
    @IBOutlet weak var newActivityDesc: UITextField!
    
    var activity: Activity!
    var activities: [Activity]!
    var goal: Goal!
    var goals: [Goal]!


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func onSaveActivityButton(_ sender: Any) {
        
        let acivityName = newActivityText.text
        let activityDesc = newActivityDesc.text
        
        if !(acivityName?.isEmpty)! {
            let params = ["activityName": acivityName!, "activityDesc": activityDesc!] as [String : Any]
            ParseClient.sharedInstance.saveNewActivity(params: params as NSDictionary?) { (PFObject, Error) -> () in
                if Error != nil {
                    NSLog("Error saving to Parse")
                } else {
                    NSLog("Saved activity to Parse")
                }
            }
        }
    }
    
    
    @IBAction func onGetActivityButton(_ sender: Any) {
        ParseClient.sharedInstance.getActivities() { (activities: [Activity]?, error: Error?) -> Void in
            if error != nil {
                NSLog("Error getting activities from Parse")
            } else {
                self.activities = activities!
                NSLog("Items from Parse")
            }
        }
        
    }
    
    @IBAction func onSetGoalButton(_ sender: Any) {
        //        activity.user_id = "2011AFF9-BA54-4669-9454-757CDCDF847C"
        //        activity.activity_name = "walk"
        let gvc = GoalSettingViewController(nibName: "GoalSettingViewController", bundle: nil)
        //        gvc.activity = activity;
        gvc.activityName = "walk"
        gvc.goalSetting = "Update"
        navigationController?.pushViewController(gvc, animated: true)
    }
    
    @IBAction func onGetGoalButton(_ sender: Any) {
        ParseClient.sharedInstance.getGoals() { (goals: [Goal]?, error: Error?) -> Void in
            if error != nil {
                NSLog("Error getting goals from Parse")
            } else {
                self.goals = goals!
                NSLog("Items from Parse")
            }
        }
        
        
    }
    


}
