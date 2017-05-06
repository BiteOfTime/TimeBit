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
            print("Userid", User.userId!)
            return currentUser
        } else {
            User.currentUser = User.userId // set the current user, saves in NSDefaults to persist user
            print("Userid", User.userId!)
            return User.userId
        }
    }
    
    func saveMultipleActivities(activities: [Activity?], completion: @escaping (_ parseObj: [PFObject]?, _ error: Error?) -> ()) {
        var activityObjects: [PFObject] = []
        for activity in activities {
            let activityEntry = PFObject(className: "ActivityTest")
            print("activity", activity!)
            
            let imageData = UIImagePNGRepresentation(activity!.activityImage!)
            
            // Add relevant fields to the object
            activityEntry["user_id"] = getCurrentUser()
            activityEntry["activity_name"] = activity!.activityName!
            activityEntry["activity_desc"] = activity!.activityDescription!
            //activityEntry["activity_image"] = activity!.activityImage!
            activityEntry["activity_image"] = PFFile(name: "\(activity!.activityName!).png", data: imageData!)


            activityObjects.append(activityEntry)
        }
        do {
            try PFObject.saveAll(activityObjects)
        } catch let error {
            print("There was a problem, check error.description", error.localizedDescription as Any)
            completion(nil, error)
            return
        }
        completion(activityObjects, nil)
    }
    
    func saveNewActivity(params: NSDictionary?, completion: @escaping (_ parseObj: PFObject?, _ error: Error?) -> ()) {
        // Create Parse object PFObject
        let activityEntry = PFObject(className: "ActivityTest")
       // let imageData = UIImagePNGRepresentation(params!["activityImage"]! as! UIImage)
        
        print("params")
        print(params as Any)
        
        // Add relevant fields to the object
        activityEntry["user_id"] = getCurrentUser()
        activityEntry["activity_name"] = params!["activityName"] as! String
        activityEntry["activity_desc"] = params!["activityDesc"] as! String
       // activityEntry["activity_image"] = PFFile(name: "\(params!["activityImage"]!).png", data: imageData!)
        
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
                var PFActivities = objects
//                for object in objects! {
//                    print(object.objectId!)
//                }
                let activities = Activity.ActivitiesWithArray(dictionaries: PFActivities!)
                //print(objects as Any)
                completion(activities, nil)
            } else {
                NSLog("error: \(String(describing: error))")
                completion(nil, error)
            }
        }

    }
    
    func saveNewGoal(params: NSDictionary?, completion: @escaping (_ parseObj: PFObject?, _ error: Error?) -> ()) {
        // Create Parse object PFObject
        let goalEntry = PFObject(className: "GoalTest")
        
        print("params")
        print(params as Any)
        
        // Add relevant fields to the object
        goalEntry["user_id"] = getCurrentUser()
        goalEntry["activity_name"] = params!["activityName"] as! String
        goalEntry["limit"] = params!["limit"] as! String
        goalEntry["hours"] = params!["hours"] as! String
        goalEntry["mins"] = params!["mins"] as! String
        goalEntry["frequency"] = params!["frequency"] as! String
        
        // Save object (following function will save the object in Parse asynchronously)
        goalEntry.saveInBackground { (success: Bool, error: Error?) in
            if success {
                print("Inside completion", goalEntry)
                completion(goalEntry, nil)
            } else {
                print("There was a problem, check error.description", error?.localizedDescription as Any)
                completion(nil, error)
            }
        }
    }
    
    func getGoals(completion: @escaping (_ goals: [Goal]?, _ error: Error?) -> ()) {
        let goalQuery = PFQuery(className: "GoalTest")
        goalQuery.whereKey("user_id", equalTo: getCurrentUser()!)
        //goalQuery.whereKey("activity_name", equalTo: activityName!)
        
        goalQuery.findObjectsInBackground { (objects, error) -> Void in
            if error == nil {
                let PFGoals = objects
                let goals = Goal.GoalsWithArray(dictionaries: PFGoals!)
                print(objects as Any)
                completion(goals, nil)
            } else {
                NSLog("error: \(String(describing: error))")
                completion(nil, error)
            }
        }
    }
    
    func getActivityGoals(activityName: String?, completion: @escaping (_ goal: Goal?, _ error: Error?) -> ()) {
        let goalQuery = PFQuery(className: "GoalTest")
        goalQuery.whereKey("user_id", equalTo: getCurrentUser()!)
        goalQuery.whereKey("activity_name", equalTo: activityName!)
        
        goalQuery.getFirstObjectInBackground { (object, error) -> Void in
            if error == nil {
                let PFGoal = object
                let goal = Goal.init(pfobj: PFGoal!)
                print(object as Any)
                completion(goal, nil)
            } else {
                NSLog("error: \(String(describing: error))")
                completion(nil, error)
            }
        }
    }
    
    func updateGoal(params: NSDictionary?, completion: @escaping (_ parseObj: PFObject?, _ error: Error?) -> ()) {
        let goalQuery = PFQuery(className: "GoalTest")
        goalQuery.whereKey("user_id", equalTo: getCurrentUser()!)
        goalQuery.whereKey("activity_name", equalTo: params!["activityName"] as! String)
        
        goalQuery.getFirstObjectInBackground {(object, error) -> Void in
            if error != nil {
                print(error)
            } else {
                if let object = object {
                    object["limit"] = params!["limit"] as! String
                    object["hours"] = params!["hours"] as! String
                    object["mins"] = params!["mins"] as! String
                    object["frequency"] = params!["frequency"] as! String
                }
                object!.saveInBackground()
            }
        }
    }
    
    func deleteGoal(params: NSDictionary?, completion: @escaping (_ parseObj: PFObject?, _ error: Error?) -> ()) {
        let goalQuery = PFQuery(className: "GoalTest")
        goalQuery.whereKey("user_id", equalTo: getCurrentUser()!)
        goalQuery.whereKey("activity_name", equalTo: params!["activityName"] as! String)
        
        goalQuery.getFirstObjectInBackground {(object, error) -> Void in
            if error != nil {
                print(error)
            } else {
//                if let object = object {
//                    object["limit"] = params!["limit"] as! String
//                    object["hours"] = params!["hours"] as! String
//                    object["mins"] = params!["mins"] as! String
//                    object["frequency"] = params!["frequency"] as! String
//                }
                object!.deleteInBackground()
            }
        }
    }
    
    func deleteActivity(params: NSDictionary?, completion: @escaping (_ parseObj: PFObject?, _ error: Error?) -> ()) {
        let goalQuery = PFQuery(className: "ActivityTest")
        goalQuery.whereKey("user_id", equalTo: getCurrentUser()!)
        goalQuery.whereKey("activity_name", equalTo: params!["activityName"] as! String)
        
        goalQuery.getFirstObjectInBackground {(object, error) -> Void in
            if error != nil {
                print(error!)
            } else {
                object!.deleteInBackground()
            }
        }
    }
    
    func saveActivityLog(params: NSDictionary?, completion: @escaping (_ parseObj: PFObject?, _ error: Error?) -> ()) {
        // Create Parse object PFObject
        let activityLog = PFObject(className: "ActivityLog")
        
        print("params")
        print(params! as Any)
        
        // Add relevant fields to the object
        activityLog["user_id"] = getCurrentUser()
        activityLog["activity_name"] = params!["activity_name"] as! String
        activityLog["activity_start_time"] = params!["activity_start_time"] as! NSDate
        activityLog["activity_end_time"] = params!["activity_end_time"] as! NSDate
        activityLog["activity_duration"] = params!["activity_duration"] as! Int64
        activityLog["activity_event_date"] = params!["activity_event_date"] as! String
            
        
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
        activityQuery.whereKey("activity_event_date", equalTo: params!["activity_event_date"] as! String)
        
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

    func getTodayCountForAllActivities(params: NSDictionary?, completion: @escaping (_ activities: [ActivityLog]?, _ error: Error?) -> ()) {
        let activityQuery = PFQuery(className: "ActivityLog")
        activityQuery.whereKey("user_id", equalTo: getCurrentUser()!)
        activityQuery.whereKey("activity_event_date", equalTo: params!["activity_event_date"] as! String)
        
        activityQuery.findObjectsInBackground { (objects, error) -> Void in
            if error == nil {
                let PFActivities = objects
                let activity = ActivityLog.ActivityLogWithArray(dictionaries: PFActivities!)
                print("getTodayCountForActivity", objects!)
                //completion(nil, nil)
                completion(activity, nil)
            } else {
                NSLog("error: \(String(describing: error))")
                completion(nil, error)
            }
        }
    }
    
    func getTotalCountForActivity(params: NSDictionary?, completion: @escaping (_ activities: [ActivityLog]?, _ error: Error?) -> ()) {
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
    
    func getActivityLog(completion: @escaping (_ activities: [ActivityLog]?, _ error: Error?) -> ()) {
        let activityQuery = PFQuery(className: "ActivityLog")
        activityQuery.whereKey("user_id", equalTo: getCurrentUser()!)
        
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
