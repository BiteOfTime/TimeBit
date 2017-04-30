//
//  ParseClient.swift
//  TimeBit
//
//  Created by Krishna Alex on 4/25/17.
//  Copyright © 2017 BiteOfTime. All rights reserved.
//

import UIKit
import Parse

class ParseClient: NSObject {
    
    override init() {
        super.init()
        
        Parse.initialize(with: ParseClientConfiguration(block: { (configuration: ParseMutableClientConfiguration) in
            configuration.applicationId = Secrets.getApplicationId()
            configuration.clientKey = Secrets.getClientKey()
            configuration.server = Secrets.getServer()
        }))
    }
    
    class var sharedInstance: ParseClient {
        struct Static {
            static let instance = ParseClient()
        }
        return Static.instance
    }
    
    func getCurrentUser() -> String? {
        if let currentUser = User.currentUser {
            return currentUser
        } else {
            User.currentUser = User.userId // set the current user, saves in NSDefaults to persist user
            return User.userId
        }
    }
    
    
    func saveNewActivity(params: NSDictionary?, completion: @escaping (_ parseObj: PFObject?, _ error: Error?) -> ()) {
        // Create Parse object PFObject
        let activityEntry = PFObject(className: "ActivityTest")
        
        print("params")
        print(params as Any)
        
        // Add relevant fields to the object
        activityEntry["user_id"] = getCurrentUser()
        activityEntry["activity_name"] = params!["activityName"] as! String
        activityEntry["activity_desc"] = params!["activityDesc"] as! String
        
        // Save object (following function will save the object in Parse asynchronously)
        activityEntry.saveInBackground { (success: Bool, error: Error?) in
            if success {
                print("Inside completion", activityEntry)
                completion(activityEntry, nil)
            } else {
                print("There was a problem, check error.description", error?.localizedDescription as Any)
                completion(nil, error)
            }
        }
    }
    
    func getActivities(completion: @escaping (_ activities: [Activity]?, _ error: Error?) -> ()) {
        let activityQuery = PFQuery(className: "ActivityTest")
        activityQuery.whereKey("user_id", equalTo: getCurrentUser()!)
        
        activityQuery.findObjectsInBackground { (objects, error) -> Void in
            if error == nil {
                let PFActivities = objects
                let activities = Activity.ActivitiesWithArray(dictionaries: PFActivities!)
                print(objects as Any)
                completion(activities, nil)
            } else {
                NSLog("error: \(String(describing: error))")
                completion(nil, error)
            }
        }
        
        
    }
    
    
    func saveActivityLog(params: NSDictionary?, completion: @escaping (_ parseObj: PFObject?, _ error: Error?) -> ()) {
        // Create Parse object PFObject
        let activityLog = PFObject(className: "ActivityLog")
        
        print("params")
        print(params as Any)
        
        // Add relevant fields to the object
        activityLog["user_id"] = getCurrentUser()
        activityLog["activity_name"] = params!["activity_name"] as! String
        activityLog["activity_start_time"] = params!["activity_start_time"] as! NSDate
        activityLog["activity_end_time"] = params!["activity_end_time"] as! NSDate
        activityLog["activity_duration"] = params!["activity_duration"] as! Int
        activityLog["activity_date"] = params!["activity_date"] as! Date
        
        // Save object (following function will save the object in Parse asynchronously)
        activityLog.saveInBackground { (success: Bool, error: Error?) in
            if success {
                completion(activityLog, nil)
                print("Activity saved :: ", activityLog)
            } else {
                print("ERROR:: In saveActivityLog, ", error?.localizedDescription as Any)
                completion(nil, error)
            }
        }
    }
    
    func getTodayCountForActivity(params: NSDictionary?, completion: @escaping (_ activities: [ActivityLog]?, _ error: Error?) -> ()) {
        let activityQuery = PFQuery(className: "ActivityLog")
        activityQuery.whereKey("user_id", equalTo: getCurrentUser()!)
        activityQuery.whereKey("activity_name", equalTo: params!["activity_name"] as! String)
        
        activityQuery.findObjectsInBackground { (objects, error) -> Void in
            if error == nil {
                let PFActivities = objects
                let activity = ActivityLog.ActivityLogWithArray(dictionaries: PFActivities!)
                print(objects as Any)
                //completion(nil, nil)
                completion(activity, nil)
            } else {
                NSLog("error: \(String(describing: error))")
                completion(nil, error)
            }
        }
    }
    

}
