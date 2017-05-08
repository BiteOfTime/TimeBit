//
//  NotificationViewController.swift
//  TimeBit
//
//  Created by Krishna Alex on 4/29/17.
//  Copyright © 2017 BiteOfTime. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    var pendingNotifications = [String: String]()
    var pendingNotificationArray =  [[String: String]]()
    
    let weekdayDictionary = ["1" : "Sun", "2" : "Mon", "3" : "Tue", "4" : "Wed", "5" : "Thu", "6" : "Fri", "7" : "Sat"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.setLoadingScreen()
        self.navigationItem.title = "Notifications"
        
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(UINib(nibName: "NotificationTableViewCell", bundle: nil), forCellReuseIdentifier: "NotificationTableViewCell")
        
//        getPendingNotifications()
//        tableView.reloadData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getPendingNotifications()
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getPendingNotifications() {
        //Schedule the notification
        self.pendingNotificationArray.removeAll()
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { (notifications) in
        print("Count: \(notifications.count)")
        for item in notifications {
            self.pendingNotifications["identifier"] = item.identifier
            self.pendingNotifications["goal"] = item.content.body
            //let triggerString = item.trigger?.value(forKeyPath: "dateComponents") as! String
            var dateCmp = item.trigger?.value(forKeyPath: "dateComponents") as! DateComponents
            print("dateComponents", dateCmp)
            self.pendingNotifications["triggerHour"] = "\(dateCmp.hour)"
            self.pendingNotifications["triggerMin"] = "\(dateCmp.minute)"
            self.pendingNotifications["triggerWeekday"] = "\(dateCmp.weekday)" ?? "0"
                
            self.pendingNotificationArray.append(self.pendingNotifications)
            print(self.pendingNotifications)
            self.tableView.reloadData()
            }
        }
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("arrayCount" , self.pendingNotificationArray.count)
        if pendingNotificationArray != nil {
            return self.pendingNotificationArray.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //tableView.rowHeight = 90
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationTableViewCell") as! NotificationTableViewCell
        if pendingNotificationArray != nil {
            var pendingNotfcn = [String: String]()
            pendingNotfcn = self.pendingNotificationArray[indexPath.row]
            print(pendingNotfcn["identifier"])
            
            cell.activityLabel.text = pendingNotfcn["identifier"]
            cell.goalLabel.text = pendingNotfcn["goal"]
            //Int(pfobj["hours"]! as? String ?? "") ?? 0
            let triggerHr = pendingNotfcn["triggerHour"]
            let triggerMin = pendingNotfcn["triggerMin"]
            print("triggerHr", triggerHr)
            print("triggerMin", triggerMin)
            let triggerText: String!
            let weekday: String = pendingNotfcn["triggerWeekday"]!
            if (pendingNotfcn["triggerWeekday"]) == "nil" {
                triggerText = "Daily"
            } else {
                triggerText = "Weekly on day \(weekday)"
            }
            let hrString = triggerHr! + "hr "
            let minString = triggerMin! + "min "
            let triggerString = "Notify \(triggerText!)" + " at " + hrString + minString
            print(triggerString)
            cell.triggerLabel.text = triggerString
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



