//
//  GoalsViewController.swift
//  TimeBit
//
//  Created by Krishna Alex on 4/29/17.
//  Copyright © 2017 BiteOfTime. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import UserNotifications
import UserNotificationsUI

class GoalsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var goalTableView: UITableView!
    
    var goals: [Goal]!
    var goalsDictArray: [NSDictionary]!
    var goalsDict: NSDictionary!
    var limit: String!
    var hours: String!
    var mins: String!
    var frequency: String!
    var activity: Activity!
    //var activityName: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Inside GoalsViewController")
        self.navigationItem.title = "Goals"
        
        goalTableView.estimatedRowHeight = 60
        goalTableView.rowHeight = UITableViewAutomaticDimension

        goalTableView.dataSource = self
        goalTableView.delegate = self
        
        goalTableView.register(UINib(nibName: "GoalsTableViewCell", bundle: nil), forCellReuseIdentifier: "GoalsTableViewCell")
        
        getGoals()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getGoals()
    }
    
    func getGoals() {
        ParseClient.sharedInstance.getGoals { (goals: [Goal]?, error: Error?)  -> Void in
            if error != nil {
                NSLog("No current goals from Parse")
            } else {
                self.goals = goals!
                print("User goals")
                print(self.goals)
            }
            DispatchQueue.main.async(execute: {
                self.goalTableView.reloadData()
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ goalTableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if goals != nil {
            return self.goals!.count
        }
            return 1
    }
    
    func tableView(_ goalTableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        goalTableView.rowHeight = 70
        
        let cell = goalTableView.dequeueReusableCell(withIdentifier: "GoalsTableViewCell") as! GoalsTableViewCell
        if goals != nil {
        var goal:Goal
        goal = self.goals[indexPath.row]
        print(goal.activityName)
        cell.activityNameLabel?.text = goal.activityName
        let hrsString = "\(goal.hours!)" + "hr "
        let minsString = "\(goal.mins!)" + "min "
        let currentGoal = goal.limit! + " " + hrsString + minsString + goal.frequency!
        cell.goalLabel.text = currentGoal
        cell.activityImage?.tintColor = .white
        let colorArray = [UIColor.cyan, UIColor.yellow, UIColor.orange, UIColor.green, UIColor.red]
        let randomIndex = Int(arc4random_uniform(UInt32(colorArray.count)))
        cell.activityImage?.backgroundColor = colorArray[randomIndex]
            
        ParseClient.sharedInstance.getActivityDetails(activityName: goal.activityName) { (activity: Activity?, error: Error?) -> Void in
            if error != nil {
                NSLog("No current activity from Parse")
            } else {
                self.activity = activity!
                print("User activity")
                print(self.activity)
//                let colorArray = [UIColor.cyan, UIColor.yellow, UIColor.orange, UIColor.green, UIColor.red]
//                let randomIndex = Int(arc4random_uniform(UInt32(colorArray.count)))
                let pfImage = activity?.activityImageFile
                if let imageFile : PFFile = pfImage{
                    imageFile.getDataInBackground(block: { (data, error) in
                        if error == nil {
                            let image = UIImage(data: data!)
                            cell.activityImage?.image = image
                            cell.activityImage?.backgroundColor = colorArray[randomIndex]
                        } else {
                            print(error!.localizedDescription)
                        }
                    })
                }

            }
        }
        
//        let colorArray = [UIColor.cyan, UIColor.yellow, UIColor.orange, UIColor.green, UIColor.red]
//        let randomIndex = Int(arc4random_uniform(UInt32(colorArray.count)))
//        let pfImage = activity?.activityImageFile
//        if let imageFile : PFFile = pfImage{
//            imageFile.getDataInBackground(block: { (data, error) in
//                if error == nil {
//                    let image = UIImage(data: data!)
//                    cell.activityImage?.image = image
//                    cell.activityImage?.backgroundColor = colorArray[randomIndex]
//                } else {
//                    print(error!.localizedDescription)
//                }
//            })
//        }
        //cell.activityImage.image = try! UIImage(data: (imageFile.getData()))
        }
        return cell

    }
    
    func tableView(_ goalTableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ goalTableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let goal = self.goals[indexPath.row]
        let activityName = goal.activityName
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            let params = ["activityName": activityName!] as [String : Any]
            ParseClient.sharedInstance.deleteGoal(params: params as NSDictionary?, completion: { (PFObject, Error) -> () in
                if Error != nil {
                    NSLog("Error deleting goal from Parse")
                } else {
                    print("Deleted activity goal from Parse")
                }
            })
            self.goals.remove(at: indexPath.row)
            self.goalTableView.deleteRows(at: [indexPath], with: .fade)
            self.goalTableView.reloadData()
            
            //Delete the correspnding notification
            print("Removing all pending notifications for the activity")
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [activityName!])
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
