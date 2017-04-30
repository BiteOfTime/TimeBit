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

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, TimerViewDelegate, ActivityCellDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var timerView: TimerView!
    
    var activities: [Activity] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "ActivityCell", bundle: nil), forCellWithReuseIdentifier: "ActivityCell")
        loadActivities()
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
                    NSLog("Items from Parse")
                    self.activities = activities!
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    func defaultActivitiesList () -> [Activity] {
        return [Activity("Work", "Work", #imageLiteral(resourceName: "Work")),
                Activity("Eat", "Eat", #imageLiteral(resourceName: "Eat")),
                Activity("Sleep", "Sleep", #imageLiteral(resourceName: "Sleep"))]
    }
    
//    func defaultActivitiesList () -> [Activity] {
//        return [Activity("Work", "Work", convertToPFFile(#imageLiteral(resourceName: "Work"),activityName: "Work")),
//                Activity("Eat", "Eat", convertToPFFile(#imageLiteral(resourceName: "Eat"),activityName: "Eat")),
//                Activity("Sleep", "Sleep", convertToPFFile(#imageLiteral(resourceName: "Sleep"),activityName: "Sleep"))]
//    }
//    
//    func convertToPFFile(_ uiImage:UIImage, activityName: String) -> PFFile? {
//        let imageData = UIImagePNGRepresentation(uiImage)
//        let image = PFFile(name: "\(activityName).png", data: imageData!)
//        return image
//    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return activities.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ActivityCell", for: indexPath) as! ActivityCell
        
        //Loading PFFile to PFImageView
        let pfImage = activities[indexPath.row].activityImageFile
        cell.activityImageView.file = pfImage
        cell.activityImageView.loadInBackground()
        
        //cell.activityImageView.image = activities[indexPath.row].activityImage
        cell.activityNameLabel.text = activities[indexPath.row].activityName
        return cell
    }

    func timerView(onStopTimer timerView: TimerView, timeElapsed: UInt64) {
        // Call database API to save timeElapsed
        
    }
    
    func timerView(onStartTimer timerView: TimerView) {
        // Call 
    }
    
    func activityCell(onPanGesture activityCell: ActivityCell) {
        //
        let activityName = activityCell.activityNameLabel.text
        print("on tap", activityName)
    }
}
