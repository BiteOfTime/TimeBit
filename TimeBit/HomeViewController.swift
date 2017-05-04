//
//  HomeViewController.swift
//  TimeBit
//
//  Created by Anisha Jain on 4/28/17.
//  Copyright © 2017 BiteOfTime. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, ActivityCellDelegate, AddNewActivityViewControllerDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var timerView: TimerView!
    
    var activities: [Activity] = []
    var activitiesTodayLog: Dictionary<String, [ActivityLog]> = Dictionary()

    var currentActivityIndex: Int = -1
    var startDate: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "ActivityCell", bundle: nil), forCellWithReuseIdentifier: "ActivityCell")
        
        let addNewActivityButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(HomeViewController.addNewActivityAction))
        navigationItem.rightBarButtonItem = addNewActivityButton
        navigationItem.title = "Home"
        
        loadActivities()
    }
    
    func addNewActivityAction() {
        let addNewActivityViewController = AddNewActivityViewController(nibName: "AddNewActivityViewController", bundle: nil)
        navigationController?.pushViewController(addNewActivityViewController, animated: true)
        
        addNewActivityViewController.delegate = self
    }

    func loadActivities () {
        if User.currentUser == nil {
            print("User is looged in for first time")
            let activities = defaultActivitiesList()
            // Save default activities
           
            ParseClient.sharedInstance.saveMultipleActivities(activities: activities as [Activity?]) { (PFObject, Error) -> () in
                if Error != nil {
                    NSLog("Error saving to Parse")
                } else {
                    NSLog("Saved activity to Parse")
                    ParseClient.sharedInstance.getActivities() { (activities: [Activity]?, error: Error?) -> Void in
                        if error != nil {
                            NSLog("Error getting activities from Parse")
                        } else {
                            NSLog("Items from Parse")
                            self.activities = activities!
                            self.collectionView.reloadData()
                        }
                    }
                }
            }
            
        } else {
            print("User already logged in")
            ParseClient.sharedInstance.getActivities() { (activities: [Activity]?, error: Error?) -> Void in
                if error != nil {
                    NSLog("Error getting activities from Parse")
                } else {
                    NSLog("getActivities from Parse")
                    self.activities = activities!
                    let currentDate = Utils.formatDate(dateString: String(describing: Date()))
                    let params = ["activity_event_date": currentDate!] as [String : Any]
                    ParseClient.sharedInstance.getTodayCountForAllActivities(params: params as NSDictionary?) { (activities: [ActivityLog]?, error: Error?) -> Void in
                        if error != nil {
                            NSLog("Error getting activities from Parse")
                        } else {
                            for activity in activities! {
                                var activityLogs = self.activitiesTodayLog[activity.activity_name!] ?? []
                                activityLogs.append(activity)
                                self.activitiesTodayLog[activity.activity_name!] = activityLogs
                                
                            }
                            NSLog("Items from Parse for getTodayCountForActivity \(self.activitiesTodayLog)")
                            self.collectionView.reloadData()
                        }
                    }
                }
            }
                
        }
    }
    
    func defaultActivitiesList () -> [Activity] {
        return [Activity("Work", "Work", #imageLiteral(resourceName: "Work")),
                Activity("Eat", "Eat", #imageLiteral(resourceName: "Eat")),
                Activity("Sleep", "Sleep", #imageLiteral(resourceName: "Sleep")),
                Activity("Read", "Read", #imageLiteral(resourceName: "Read")),
                Activity("Walk", "Walk", #imageLiteral(resourceName: "Walk")),
                Activity("Internet", "Internet", #imageLiteral(resourceName: "Internet")),
                Activity("Shop", "Shop", #imageLiteral(resourceName: "Shop")),
                Activity("Excercise", "Excercise", #imageLiteral(resourceName: "Exercise")),
                Activity("Sport", "Sport", #imageLiteral(resourceName: "Sport"))]
    }
    
    func convertToPFFile(_ uiImage:UIImage, activityName: String) -> PFFile? {
        let imageData = UIImagePNGRepresentation(uiImage)
        let image = PFFile(name: "\(activityName).png", data: imageData!)
        return image
    }
    
    func addNewActivityViewController(onSaveActivity newActivity: Activity) {
        activities.append(newActivity)
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return activities.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ActivityCell", for: indexPath) as! ActivityCell
        cell.delegate = self
        
        cell.layer.borderColor = UIColor.darkGray.cgColor
        cell.layer.borderWidth = 0.5
        cell.isSelected = indexPath.row == currentActivityIndex
        
        //Loading PFFile to PFImageView
        let activity = activities[indexPath.row]
        let pfImage = activity.activityImageFile
        if let imageFile : PFFile = pfImage{
            imageFile.getDataInBackground(block: { (data, error) in
                if error == nil {
                    let image = UIImage(data: data!)
                    cell.activityImage.setImage(image, for: UIControlState.normal)
                    cell.activityImage.setImage(image, for: UIControlState.selected)
                } else {
                    print(error!.localizedDescription)
                }
            })
        }
        
        cell.activityImage.tintColor = .white
        cell.activityNameLabel.text = activity.activityName
        let activityLog = activitiesTodayLog[activity.activityName!]
        let totalTimeSpentToday = getTimeSpentToday(activityLog: activityLog )
        if totalTimeSpentToday == "0" {
            cell.timeSpentLabel.isHidden = true
        } else {
            cell.timeSpentLabel.isHidden = false
            cell.timeSpentLabel.text = totalTimeSpentToday
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width/2, height: 100);
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailActivityViewController = DetailActivityViewController(nibName: "DetailActivityViewController", bundle: nil)
        detailActivityViewController.activity_name = activities[indexPath.row].activityName!
        navigationController?.pushViewController(detailActivityViewController, animated: true)
    }

    func getTimeSpentToday(activityLog: [ActivityLog]?) -> String {
        if(activityLog == nil || activityLog?.count == 0) {
            return "0"
        }
        var totalTimeSpentToday: Int64 = 0
        for log in activityLog! {
            if log.activity_duration != nil {
                totalTimeSpentToday += Int64(log.activity_duration!)
            }
        }
        let seconds = totalTimeSpentToday % 60
        let minutes = totalTimeSpentToday / 60
        let hours = totalTimeSpentToday / 3600
        //print("totalTimeSpentToday:", totalTimeSpentToday)
        
        if hours > 0 {
            return minutes > 0 ? "\(hours)hr \(minutes)min today" : "\(hours)hr today"
        }
        
        if minutes > 0 {
            return seconds > 0  ? "\(minutes)min \(seconds)sec today" : "\(minutes)min today"
        }
        
        return "\(seconds)sec today"

    }
    
    func activityCell(onStartStop activityCell: ActivityCell) {
        let clickActivityIndex = collectionView.indexPath(for: activityCell)!.row
        if currentActivityIndex == -1 {
            activityCell.isSelected = true
            currentActivityIndex = (collectionView.indexPath(for: activityCell)?.row)!
            //print("Timer started")
            startDate = Date()
            timerView.onStartTimer()
        } else if clickActivityIndex == currentActivityIndex {
            activityCell.isSelected = false
            currentActivityIndex = -1
            //print("Timer Stopped")
            let passedSeconds = timerView.onStopTimer()
            
            let currentDate = Utils.formatDate(dateString: String(describing: Date()))
            
            if (!(activityCell.activityNameLabel.text?.isEmpty)!) {
                let params = ["activity_name": activityCell.activityNameLabel.text!, "activity_start_time": startDate!, "activity_end_time": Date(), "activity_duration": passedSeconds, "activity_event_date": currentDate!] as Dictionary
                
                //Showing locally
                var activityLogs = self.activitiesTodayLog[activityCell.activityNameLabel.text!] ?? []
                activityLogs.append(ActivityLog(dictionary: params))
                self.activitiesTodayLog[activityCell.activityNameLabel.text!] = activityLogs
                self.collectionView.reloadData()
                
                ParseClient.sharedInstance.saveActivityLog(params: params as NSDictionary?) { (PFObject, Error) -> () in
                    if Error != nil {
                        NSLog("Error saving to the log for the activity")
                    } else {
                        NSLog("Saved the activity for", activityCell.activityNameLabel.text!)
                    }
                }
            }
            
            startDate = nil
        }
    }
}
