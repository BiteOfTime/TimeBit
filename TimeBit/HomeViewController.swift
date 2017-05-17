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
import UserNotifications
import UserNotificationsUI

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, ActivityCellDelegate, AddNewActivityViewControllerDelegate, UICollectionViewDelegateFlowLayout, TimerViewDeleagte, DetailActivityViewControllerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var timerView: TimerView!
    @IBOutlet weak var activityLineView: UIView!
    
    var roundButton = UIButton()
    var reusableView : UICollectionReusableView? = nil
    
    var activities: [Activity] = []
    var activitiesTodayLog: Dictionary<String, [ActivityLog]> = Dictionary()
    
    var currentActivityIndex: Int = -1
    var startDate: Date?
    var activityRunning: Dictionary = [String: Any]()
    var selectedCell = [IndexPath]()
    
    var initialIndexPath: IndexPath?
    var cellSnapshot: UIView?
    var longPressActive = false
    var touchLocation:CGPoint? = nil
    
    var rearrangeCellSelectedIndex:Int? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "ActivityCell", bundle: nil), forCellWithReuseIdentifier: "ActivityCell")
        collectionView.allowsSelection = true
        
//        collectionView.layer.borderWidth = 0.4
//        collectionView.layer.borderColor = UIColor(red: 54/255, green: 69/255, blue: 86/255, alpha: 1.0).cgColor
        
        navigationController?.navigationBar.layer.shadowOffset = CGSize(width:0, height: 0)
        navigationController?.navigationBar.layer.shadowRadius = 3
        navigationController?.navigationBar.layer.shadowColor = UIColor.black.cgColor
        navigationController?.navigationBar.layer.shadowOpacity = 0.8
        navigationItem.title = "Home"
        
        //Floating round button to add a new activity
        self.roundButton = UIButton(type: .custom)
        self.roundButton.setTitleColor(UIColor.orange, for: .normal)
        self.roundButton.addTarget(self, action: #selector(ButtonClick(_:)), for: UIControlEvents.touchUpInside)
        self.view.addSubview(roundButton)
        timerView.delegate = self
        
        let shadowSize : CGFloat = 5.0
        let shadowPath = UIBezierPath(rect: CGRect(x: -shadowSize / 2,
                                                   y: -shadowSize / 2,
                                                   width: self.activityLineView.frame.size.width + shadowSize,
                                                   height: self.activityLineView.frame.size.height + shadowSize))
        activityLineView.layer.masksToBounds = false
        activityLineView.layer.shadowColor = UIColor(red: 0.12, green: 0.67, blue: 1.0, alpha: 1.0).cgColor
        activityLineView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        activityLineView.layer.shadowRadius = 2
        activityLineView.layer.shadowOpacity = 0.3
        activityLineView.layer.shadowPath = shadowPath.cgPath
        
        loadActivities()
        addLongPressGesture()
        addTapGesture()
        self.becomeFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(forName: AppDelegate.goingInBackground, object: nil, queue: OperationQueue.main) { (notification) in
            if UserDefaults.standard.object(forKey: "FireBackgroundTime") != nil {
                print("Delete previous ", UserDefaults.standard.object(forKey: "FireBackgroundTime")!)
                UserDefaults.standard.removeObject(forKey: "FireBackgroundTime")
            }
            guard let timer = self.timerView.timer else {return}
            UserDefaults.standard.set(timer.fireDate, forKey: "FireBackgroundTime")
            print("FireDate when going in background", UserDefaults.standard.value(forKey: "FireBackgroundTime")!)
            timer.invalidate()
        }
        
        NotificationCenter.default.addObserver(forName: AppDelegate.comingToForeground, object: nil, queue: OperationQueue.main) { (notification) in
            if let fireDate = UserDefaults.standard.object(forKey: "FireBackgroundTime") {
                // setup a timer with the correct fire date
                let elapsedTime = Date().timeIntervalSince(fireDate as! Date)
                print("time gap", elapsedTime)
                if elapsedTime > 0 {
                    self.timerView.updateBackgroundTimer(elapsedTime: Int64(elapsedTime))
                }
            }
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    // Enable detection of shake motion
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            if timerView.isRunning {
                print("Stopping timer on shake detection")
                let passedSeconds = timerView.onStopTimer()
                timerView.isRunning = false
                timerView(onStop: passedSeconds)
            }
            print("Shaking")
        }
    }

    func loadActivities () {
        if User.currentUser == nil {
            print("User is looged in for first time")
            let overlayViewController = OverlayView(nibName: "OverlayView", bundle: nil)
            overlayViewController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            self.present(overlayViewController, animated: true, completion: nil)
            
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
    
    func addLongPressGesture() {
        let longpress = UILongPressGestureRecognizer(target: self, action: #selector(onLongPressGesture(sender:)))
        collectionView.addGestureRecognizer(longpress)
    }
    
    func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapGesture(sender:)))
        collectionView.addGestureRecognizer(tapGesture)
    }
    
    func onTapGesture(sender: UITapGestureRecognizer) {
        if longPressActive {
            longPressActive = false
            collectionView.reloadData()
        } else {
            let locationInView = sender.location(in: collectionView)
            let indexPath = collectionView.indexPathForItem(at: locationInView)
            let tapOnActivity = activities[(indexPath?.row)!].activityName!
            let detailActivityViewController = DetailActivityViewController(nibName: "DetailActivityViewController", bundle: nil)
            detailActivityViewController.activity_name = tapOnActivity
            print("passing the value of isTimerOn to detailVC \(currentActivityIndex)")
            if !self.activityRunning.isEmpty {
                let activityRunning = self.activityRunning["activity_name"] as! String
                detailActivityViewController.activityRunning = activityRunning
                if (activityRunning == tapOnActivity && currentActivityIndex != -1) {
                    detailActivityViewController.isTimerOn = 0
                } else {
                    detailActivityViewController.isTimerOn = -1
                }
            } else {
                detailActivityViewController.isTimerOn = currentActivityIndex
            }
            
            detailActivityViewController.anyActivityRunning = self.timerView.isRunning
            detailActivityViewController.currentHour = self.timerView.hours
            detailActivityViewController.currentMinute = self.timerView.minutes
            detailActivityViewController.currentSec = self.timerView.seconds
            detailActivityViewController.trackPassedSecond = self.timerView.passedSeconds
            detailActivityViewController.activityStartTimeFromHomeScreen = self.startDate ?? Date()
            detailActivityViewController.delegate = self
            
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            navigationController?.pushViewController(detailActivityViewController, animated: true)
            
        }
    }
    
    func onLongPressGesture(sender: UILongPressGestureRecognizer) {
        
        let locationInView = sender.location(in: view)
        let locationInCollectionView = sender.location(in: collectionView)
        let collectionViewLocation = collectionView.convert(collectionView.bounds.origin, to: view)
        
        if sender.state == .began {
            touchLocation = locationInView
            let indexPath = collectionView.indexPathForItem(at: locationInCollectionView)
            rearrangeCellSelectedIndex = indexPath?.row
            if indexPath != nil {
                initialIndexPath = indexPath
                let cell = collectionView.cellForItem(at: indexPath!)
                cellSnapshot = snapshotOfCell(inputView: cell!)
                cell?.isHidden = true
                
                let locationOnScreen = cell!.convert(cell!.bounds.origin, to: view)
                let cellBounds = cell!.bounds
                let center = CGPoint(x:(locationOnScreen.x + cellBounds.size.width / 2),
                                     y : (locationOnScreen.y + cellBounds.size.height / 2))
                    
                cellSnapshot?.center = center
                cellSnapshot?.alpha = 1.0
                cellSnapshot?.transform = (self.cellSnapshot?.transform.scaledBy(x: 1.05, y: 1.05))!
                view.addSubview(cellSnapshot!)
                longPressActive = true
                collectionView.reloadData()
            }
        } else if sender.state == .changed {
            
            let isInsideCollectionView = locationInView.y > collectionViewLocation.y
            var center = cellSnapshot?.center
            center?.y = center!.y + (locationInView.y - touchLocation!.y)
            center?.x = center!.x + (locationInView.x - touchLocation!.x)
            touchLocation = locationInView
            cellSnapshot?.center = center!
            if (isInsideCollectionView) {
                if currentActivityIndex == -1 {
                    timerView.zoomOutTimerView()
                }
                let indexPath = collectionView.indexPathForItem(at: locationInCollectionView)
                if ((indexPath != nil) && (indexPath != initialIndexPath)) {
                    //swap(&activities[indexPath!.row], &activities[initialIndexPath!.row])
                    collectionView.moveItem(at: initialIndexPath!, to: indexPath!)
                    initialIndexPath = indexPath
                }
            } else {
                // if any activity is not running then only zoomin the clock
                if currentActivityIndex == -1 {
                     timerView.zoomInTimerView()
                }
            }
        } else if sender.state == .ended {
            touchLocation = nil
            let cell = collectionView.cellForItem(at: initialIndexPath!) as! ActivityCell
            let isInsideCollectionView = locationInView.y > collectionViewLocation.y
            //print("location in view", locationInView)
            //print("collection view location", collectionViewLocation)
            
            if (isInsideCollectionView) {
                // if any activity is not running then only zoomout the clock
                if currentActivityIndex == -1 {
                    timerView.zoomOutTimerView()
                }
                
                let indexPath = collectionView.indexPathForItem(at: locationInCollectionView)
                
                let locationOnScreen = cell.convert(cell.bounds.origin, to: view)
                let cellBounds = cell.bounds
                let center = CGPoint(x:(locationOnScreen.x + cellBounds.size.width / 2),
                                     y : (locationOnScreen.y + cellBounds.size.height / 2))
                
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    self.cellSnapshot?.center = center
                }, completion: { (finished) -> Void in
                    if finished {
                        if (indexPath?.row != self.rearrangeCellSelectedIndex) {
                            self.activities.rearrange(from: self.rearrangeCellSelectedIndex!, to: indexPath!.row)
                        }
                        self.rearrangeCellSelectedIndex = nil
                        self.initialIndexPath = nil
                        self.cellSnapshot?.removeFromSuperview()
                        self.cellSnapshot = nil
                        self.collectionView.reloadData()
                    }
                })
            }

            else {
                longPressActive = false
                rearrangeCellSelectedIndex = nil
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    self.cellSnapshot?.transform = (self.cellSnapshot?.transform.scaledBy(x: 0.4, y: 0.4))!
                    self.cellSnapshot?.alpha = 0
                }, completion: { (finished) -> Void in
                    if finished {
                        let cellIndex = self.initialIndexPath?.row
                        self.initialIndexPath = nil
                        self.cellSnapshot?.removeFromSuperview()
                        self.cellSnapshot = nil
                        self.startTimer(activityName: cell.activityNameLabel.text!, cellIndex: cellIndex!)
        
                        self.collectionView.reloadData()
                    }
                })
                
            }
        
        }
    }
    
    func snapshotOfCell(inputView: UIView) -> UIView {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let cellSnapshot = UIImageView(image: image)
        cellSnapshot.layer.masksToBounds = false
        cellSnapshot.layer.cornerRadius = 0.0
        cellSnapshot.layer.shadowOffset = CGSize(width: -5.0, height: 5.0)
        cellSnapshot.layer.shadowRadius = 5.0
        cellSnapshot.layer.shadowOpacity = 0.4
        return cellSnapshot
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return activities.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ActivityCell", for: indexPath) as! ActivityCell
        cell.delegate = self

        cell.layer.borderColor = UIColor(red: 54/255, green: 69/255, blue: 86/255, alpha: 1.0).cgColor
        cell.layer.borderWidth = 0.4
//        if currentActivityIndex != indexPath.row {
//            changeColorOfCell(activityCell: cell, index: indexPath.row)
//        }
        
        //cell.activityImage.isSelected = indexPath.row == currentActivityIndex
        
        //Loading PFFile to PFImageView
        let activity = activities[indexPath.row]
        let pfImage = activity.activityImageFile
        if let imageFile : PFFile = pfImage{
            imageFile.getDataInBackground(block: { (data, error) in
                if error == nil {
                    let image = UIImage(data: data!)
                    cell.activityImage.image = image
                    cell.activityImage.image = cell.activityImage.image!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                    cell.activityImage.backgroundColor = CustomUIFunctions.imageBackgroundColor(index: indexPath.row)
                    cell.activityImageView.backgroundColor = CustomUIFunctions.imageBackgroundColor(index: indexPath.row)
                    cell.activityImage.tintColor = .white
                } else {
                    print(error!.localizedDescription)
                }
            })
        }
        
        cell.activityNameLabel.text = activity.activityName
        let activityLog = activitiesTodayLog[activity.activityName!]
        let totalTimeSpentToday = getTimeSpentToday(activityLog: activityLog )
        if totalTimeSpentToday == "0" {
            cell.timeSpentLabel.isHidden = true
        } else {
            cell.timeSpentLabel.isHidden = false
            cell.timeSpentLabel.text = totalTimeSpentToday
        }
        
        if longPressActive && initialIndexPath == indexPath {
            cell.isHidden = true
        } else {
            cell.isHidden = false
        }
        
        if longPressActive && cell.transform == CGAffineTransform.identity {
            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                cell.transform = (cell.transform.scaledBy(x: 0.9, y: 0.9))
            })
            cell.deleteActivityButton.isHidden = false
            
        } else if !longPressActive && !cell.deleteActivityButton.isHidden {
            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                cell.transform = CGAffineTransform.identity
            })
            cell.deleteActivityButton.isHidden = true
        }
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width/2, height: 130);
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.contentView.backgroundColor = .blue
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
        let minutes = (totalTimeSpentToday / 60) % 60
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
    
    func detailActivityViewController(stopActivityDetails: Dictionary<String, Any>) {
        currentActivityIndex = -1
        timerView.activityNameLabel.text = "START AN ACTIVITY"
        timerView.isRunning = false
        timerView.timer.invalidate()
        timerView.resetTimer()
        
        let activityName = stopActivityDetails["activity_name"] as! String
        var activityLogs = self.activitiesTodayLog[activityName] ?? []
        activityLogs.append(ActivityLog(dictionary: stopActivityDetails))
        self.activitiesTodayLog[activityName] = activityLogs
        self.activityRunning["activity_name"] = nil
        self.activityRunning["activity_start_time"] = nil
        self.collectionView.reloadData()
    }
    
    func detailActivityViewController(startActivityName: String) {
        currentActivityIndex = 0
        print("Timer started")
        startDate = Date()
        activityRunning["activity_name"] = startActivityName
        activityRunning["activity_start_time"] = startDate
        timerView.activityNameLabel.text = "\(startActivityName.capitalized) in progress!"
        //timerView.stopLabel.isHidden = false
        timerView.onStartTimer()
    }
    
    func startTimer(activityName: String, cellIndex: Int) {
        if currentActivityIndex == -1 {
            //activityCell.activityImage.isSelected = true
            currentActivityIndex = cellIndex
            print("Timer started")
            startDate = Date()
            activityRunning["activity_name"] = activityName
            activityRunning["activity_start_time"] = startDate
            timerView.activityNameLabel.text = "\(activityName.capitalized) in progress!"
            //timerView.stopLabel.isHidden = false
            timerView.onStartTimer()
        } else {
            let activityAlreadyRunning = activityRunning["activity_name"] as! String
            let alert = UIAlertController(title: "TimeBit",
                                          message: "'\(activityAlreadyRunning.capitalized)' already running. Stop '\(activityAlreadyRunning.capitalized)' to start '\(activityName)'",
                preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: { (action) -> Void in
                print("OK")
            })
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
    }
    
    func timerView(onStop passedSeconds: Int64) {
        currentActivityIndex = -1
        //print("Timer Stopped")
        timerView.activityNameLabel.text = "START AN ACTIVITY"
        let currentDate = Utils.formatDate(dateString: String(describing: Date()))
        let activityName = activityRunning["activity_name"] as! String
        if (!activityName.isEmpty) {
            let params = ["activity_name": activityName, "activity_start_time":activityRunning["activity_start_time"]!, "activity_end_time": Date(), "activity_duration": passedSeconds, "activity_event_date": currentDate!] as Dictionary
            
            //Showing locally
            var activityLogs = self.activitiesTodayLog[activityName] ?? []
            activityLogs.append(ActivityLog(dictionary: params))
            self.activitiesTodayLog[activityName] = activityLogs
            self.collectionView.reloadData()
            
            ParseClient.sharedInstance.saveActivityLog(params: params as NSDictionary?) { (PFObject, Error) -> () in
                if Error != nil {
                    NSLog("Error saving to the log for the activity")
                } else {
                    NSLog("Saved the activity for", activityName)
                    self.activityRunning["activity_name"] = nil
                    self.activityRunning["activity_start_time"] = nil
                }
            }
        }
        startDate = nil
    }
    
//    func activityCell(onStartStop activityCell: ActivityCell) {
//        let clickActivityIndex = collectionView.indexPath(for: activityCell)!.row
//        if currentActivityIndex == -1 {
//            activityCell.activityImage.isSelected = true
//            currentActivityIndex = (collectionView.indexPath(for: activityCell)?.row)!
//            //print("Timer started")
//            startDate = Date()
//            timerView.timerRunning = true
//            timerView.onStartTimer()
//        } else if currentActivityIndex == currentActivityIndex {
//            activityCell.activityImage.isSelected = false
//            currentActivityIndex = -1
//            //print("Timer Stopped")
//            let passedSeconds = timerView.onStopTimer()
//            
//            let currentDate = Utils.formatDate(dateString: String(describing: Date()))
//            
//            if (!(activityCell.activityNameLabel.text?.isEmpty)!) {
//                let params = ["activity_name": activityCell.activityNameLabel.text!, "activity_start_time": startDate!, "activity_end_time": Date(), "activity_duration": passedSeconds, "activity_event_date": currentDate!] as Dictionary
//                
//                //Showing locally
//                var activityLogs = self.activitiesTodayLog[activityCell.activityNameLabel.text!] ?? []
//                activityLogs.append(ActivityLog(dictionary: params))
//                self.activitiesTodayLog[activityCell.activityNameLabel.text!] = activityLogs
//                self.collectionView.reloadData()
//                
//                ParseClient.sharedInstance.saveActivityLog(params: params as NSDictionary?) { (PFObject, Error) -> () in
//                    if Error != nil {
//                        NSLog("Error saving to the log for the activity")
//                    } else {
//                        NSLog("Saved the activity for", activityCell.activityNameLabel.text!)
//                    }
//                }
//            }
//            
//            startDate = nil
//        }
//    }
    
    func activityCell(onDeleteActivity activityCell: ActivityCell) {
        let alert = UIAlertController(title: "TimeBit",
                                      message: "Do you really want delete '\(activityCell.activityNameLabel!.text!)' activity?",
            preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Delete", style: .default, handler: { (action) -> Void in
            
            let index = self.collectionView.indexPath(for: activityCell)!.row
            self.activities.remove(at: index)

            let params = ["activityName": activityCell.activityNameLabel!.text!] as [String : Any]
            ParseClient.sharedInstance.deleteActivity(params: params as NSDictionary?, completion: { (PFObject, Error) -> () in
                if Error != nil {
                    NSLog("Error deleting activity from Parse")
                } else {
                    print("Deleted activity from Parse")
                }
            })
            ParseClient.sharedInstance.deleteGoal(params: params as NSDictionary?, completion: { (PFObject, Error) -> () in
                if Error != nil {
                    NSLog("Error deleting goal from Parse")
                } else {
                    print("Deleted activity goal from Parse")
                }
            })
            ParseClient.sharedInstance.deleteActivityLog(params: params as NSDictionary?, completion: { (PFObject, Error) -> () in
                if Error != nil {
                    NSLog("Error deleting activity logs from Parse")
                } else {
                    print("Deleted activity logs from Parse")
                }
            })
            //Delete the correspnding notification
            print("Removing all pending notifications for the activity")
            let center = UNUserNotificationCenter.current()
            let notificationIdentifier = activityCell.activityNameLabel!.text!
            center.removePendingNotificationRequests(withIdentifiers: [notificationIdentifier])
            self.collectionView.reloadData()
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in })
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    override func viewWillLayoutSubviews() {
        roundButton.layer.cornerRadius = roundButton.layer.frame.size.width / 2
        roundButton.backgroundColor = UIColor.clear
        roundButton.clipsToBounds = true
        roundButton.setImage(UIImage(named:"Add"), for: .normal)
        roundButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            roundButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            roundButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -3),
            roundButton.widthAnchor.constraint(equalToConstant: 40),
            roundButton.heightAnchor.constraint(equalToConstant:40)])
    }
    
    @IBAction func ButtonClick(_ sender: UIButton){
        let addNewActivityViewController = AddNewActivityViewController(nibName: "AddNewActivityViewController", bundle: nil)
         self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.pushViewController(addNewActivityViewController, animated: true)
        
        addNewActivityViewController.delegate = self
        
    }
}

extension Array {
    mutating func rearrange(from: Int, to: Int) {
        insert(remove(at: from), at: to)
    }
}
