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
    
    var goals: [Goal] = []
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
        navigationController?.navigationBar.layer.shadowOffset = CGSize(width:0, height: 0)
        navigationController?.navigationBar.layer.shadowRadius = 3
        navigationController?.navigationBar.layer.shadowColor = UIColor.black.cgColor
        navigationController?.navigationBar.layer.shadowOpacity = 0.8
        
//        goalTableView.rowHeight = UITableViewAutomaticDimension
//        goalTableView.estimatedRowHeight = 100

        goalTableView.dataSource = self
        goalTableView.delegate = self
        goalTableView.tableFooterView = UIView(frame: CGRect.zero)
        
        goalTableView.register(UINib(nibName: "GoalsTableViewCell", bundle: nil), forCellReuseIdentifier: "GoalsTableViewCell")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getGoals()
    }
    
    func getGoals() {
        print("inside getGoals")
        ParseClient.sharedInstance.getGoals { (goals: [Goal]?, error: Error?)  -> Void in
            if error != nil {
                NSLog("No current goals from Parse")
            } else {
                self.goals = goals!
                print("User goals count")
                print(self.goals.count)
                print("User goals")
                print(self.goals)
                self.goalTableView.reloadData()
            }
            DispatchQueue.main.async(execute: {
                print("inside dispatch")
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
        print("inside numberOfRowsInSection")
        print(self.goals.count)
        return self.goals.count
    }
    
    func tableView(_ goalTableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        goalTableView.rowHeight = 75
        
        let cell = goalTableView.dequeueReusableCell(withIdentifier: "GoalsTableViewCell") as! GoalsTableViewCell
        cell.layer.borderColor = UIColor(red: 54/255, green: 69/255, blue: 86/255, alpha: 1.0).cgColor
        cell.layer.borderWidth = 0.5

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
            
            ParseClient.sharedInstance.getActivityDetails(activityName: goal.activityName) { (activity: Activity?, error: Error?) -> Void in
                if error != nil {
                    NSLog("No current activity from Parse")
                } else {
                    self.activity = activity!
                    print("User activity")
                    print(self.activity)
                    let pfImage = activity?.activityImageFile
                    if let imageFile : PFFile = pfImage{
                        imageFile.getDataInBackground(block: { (data, error) in
                            if error == nil {
                                let image = UIImage(data: data!)
                                cell.activityImage.image = image
                                cell.activityImage.image = cell.activityImage.image!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                                cell.activityImage.tintColor = .white
                                cell.activityImage.backgroundColor = CustomUIFunctions.imageBackgroundColor(index: indexPath.row)
                                cell.imageUIView.backgroundColor = CustomUIFunctions.imageBackgroundColor(index: indexPath.row)
                            } else {
                                print(error!.localizedDescription)
                            }
                        })
                    }

                }
            }
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
    
//    func tableView(_ goalTableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
//        return 90
//    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
