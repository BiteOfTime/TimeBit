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
        //collectionView.backgroundColor = .gray
        
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
                Activity("Sleep", "Sleep", #imageLiteral(resourceName: "Sleep")),
                Activity("Read", "Read", #imageLiteral(resourceName: "Read")),
                Activity("Walk", "Walk", #imageLiteral(resourceName: "Walk")),
                Activity("Internet", "Internet", #imageLiteral(resourceName: "Internet")),
                Activity("Shop", "Shop", #imageLiteral(resourceName: "Shop")),
                Activity("Excercise", "Excercise", #imageLiteral(resourceName: "Exercise")),
                Activity("Sport", "Sport", #imageLiteral(resourceName: "Sport"))]
    }
    
//    func defaultActivitiesList () -> [Activity] {
//        return [Activity("Work", "Work", convertToPFFile(#imageLiteral(resourceName: "Work"),activityName: "Work")),
//                Activity("Eat", "Eat", convertToPFFile(#imageLiteral(resourceName: "Eat"),activityName: "Eat")),
//                Activity("Sleep", "Sleep", convertToPFFile(#imageLiteral(resourceName: "Sleep"),activityName: "Sleep"))]
//    }
    
    func convertToPFFile(_ uiImage:UIImage, activityName: String) -> PFFile? {
        let imageData = UIImagePNGRepresentation(uiImage)
        let image = PFFile(name: "\(activityName).png", data: imageData!)
        return image
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return activities.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ActivityCell", for: indexPath) as! ActivityCell
        cell.delegate = self
        
        cell.layer.borderColor = UIColor.darkGray.cgColor
        cell.layer.borderWidth = 0.5
        
        //Loading PFFile to PFImageView
        let pfImage = activities[indexPath.row].activityImageFile
        if let imageFile : PFFile = pfImage{
            imageFile.getDataInBackground(block: { (data, error) in
                if error == nil {
                        let image = UIImage(data: data!)
                        cell.activityImage.setImage(image, for: UIControlState.normal)
                } else {
                    print(error!.localizedDescription)
                }
            })
        }
        
        cell.activityImage.tintColor = .white
        cell.activityNameLabel.text = activities[indexPath.row].activityName
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailActivityViewController = DetailActivityViewController(nibName: "DetailActivityViewController", bundle: nil)
        detailActivityViewController.activity_name = activities[indexPath.row].activityName!
        navigationController?.pushViewController(detailActivityViewController, animated: true);
    }

    func timerView(onStopTimer timerView: TimerView, timeElapsed: UInt64) {
        // Call database API to save timeElapsed
        
    }
    
    func timerView(onStartTimer timerView: TimerView) {
        // Call 
    }
    
    func activityCell(onStartActivity activityCell: ActivityCell) {
        let activityName = activityCell.activityNameLabel.text
        timerView.onStartTimer()
        print("Start", activityCell.activityNameLabel!.text!)
    }
    
    func activityCell(onStopActivity activityCell: ActivityCell) {
        print("Stop", activityCell.activityNameLabel!.text!)
        timerView.onStopTimer()
    }
}
