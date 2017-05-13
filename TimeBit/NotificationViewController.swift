//
//  NotificationViewController.swift
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

class NotificationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    var activity: Activity!
    var pendingNotifications = [String: String]()
    var pendingNotificationArray =  [[String: String]]()
    
    let weekdayDictionary = ["1" : "Sunday", "2" : "Monday", "3" : "Tueday", "4" : "Wednesday", "5" : "Thuday", "6" : "Friday", "7" : "Saturday"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.setLoadingScreen()
        self.navigationItem.title = "Notifications"
        navigationController?.navigationBar.layer.shadowOffset = CGSize(width:0, height: 0)
        navigationController?.navigationBar.layer.shadowRadius = 3
        navigationController?.navigationBar.layer.shadowColor = UIColor.black.cgColor
        navigationController?.navigationBar.layer.shadowOpacity = 0.8
        
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        tableView.register(UINib(nibName: "NotificationTableViewCell", bundle: nil), forCellReuseIdentifier: "NotificationTableViewCell")        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getPendingNotifications()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getPendingNotifications() {
        //Schedule the notification
        self.pendingNotificationArray.removeAll()
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests(completionHandler: { (notifications) in
        print("Count: \(notifications.count)")
            for item in notifications {
                self.pendingNotifications["identifier"] = item.identifier
                self.pendingNotifications["goal"] = item.content.body
                //let triggerString = item.trigger?.value(forKeyPath: "dateComponents") as! String
                var dateCmp = item.trigger?.value(forKeyPath: "dateComponents") as! DateComponents
                print("dateComponents", dateCmp)
                self.pendingNotifications["triggerHour"] = String(dateCmp.hour!)
                self.pendingNotifications["triggerMin"] = String(dateCmp.minute!)
                self.pendingNotifications["triggerWeekday"] = "\(dateCmp.weekday ?? 0)"
                    
                self.pendingNotificationArray.append(self.pendingNotifications)
                print(self.pendingNotifications)
            }
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            })
        })
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("arrayCount" , self.pendingNotificationArray.count)
        //if pendingNotificationArray != nil {
            return self.pendingNotificationArray.count
        //}
        //return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //tableView.rowHeight = 90
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationTableViewCell") as! NotificationTableViewCell
        cell.layer.borderColor = UIColor(red: 54/255, green: 69/255, blue: 86/255, alpha: 1.0).cgColor
        cell.layer.borderWidth = 0.5
        
        if pendingNotificationArray != nil {
            var pendingNotfcn = [String: String]()
            pendingNotfcn = self.pendingNotificationArray[indexPath.row]
            print(pendingNotfcn["identifier"])
            let activityName = pendingNotfcn["identifier"]
            cell.activityLabel.text = activityName
            cell.goalLabel.text = pendingNotfcn["goal"]
            //Int(pfobj["hours"]! as? String ?? "") ?? 0
            let triggerHr = pendingNotfcn["triggerHour"]!
            let triggerMin = pendingNotfcn["triggerMin"]!
            print("triggerHr", triggerHr)
            print("triggerMin", triggerMin)
            let triggerText: String!
            let weekday: String!
            weekday = pendingNotfcn["triggerWeekday"]!
            print(weekday)
            if (pendingNotfcn["triggerWeekday"]) == "0" {
                triggerText = "Daily"
            } else {
                let dayOfWeek = weekdayDictionary[weekday]!
                print(dayOfWeek)
                triggerText = "Weekly on \(dayOfWeek)"
            }
            let hrString = String(format: "%02d", Int(triggerHr)!) + ":"
            let minString = String(format: "%02d", Int(triggerMin)!)
            let triggerString = "Notify \(triggerText!)" + " at " + hrString + minString
            print(triggerString)
            cell.triggerLabel.text = triggerString
            ParseClient.sharedInstance.getActivityDetails(activityName: activityName) { (activity: Activity?, error: Error?) -> Void in
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
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let pendingNotificn = self.pendingNotificationArray[indexPath.row]
        let notificationIdentifier = pendingNotificn["identifier"]
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            print("Removed all pending notifications")
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [notificationIdentifier!])
            self.pendingNotificationArray.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            self.tableView.reloadData()
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



