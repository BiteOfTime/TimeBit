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

   // let secret: Secret!
    
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
    
//    func getCurrentUser() -> PFUser? {
//        return PFUser.currentUser()
//    }
    
    
    func saveNewActivity(params: NSDictionary?, completion: @escaping (_ parseObj: PFObject?, _ error: Error?) -> ()) {
        // Create Parse object PFObject
        let activityEntry = PFObject(className: "ActivityTest")
        
        print("params")
        print(params)
        
        // Add relevant fields to the object
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
        var activityQuery = PFQuery(className: "ActivityTest")
        //activityQuery.includeKey("User")
        
        activityQuery.findObjectsInBackground { (objects, error) -> Void in
            if error == nil {
                let PFActivities = objects as! [PFObject]
                let activities = Activity.ActivitiesWithArray(dictionaries: PFActivities)
                print(objects)
                completion(activities, nil)
            } else {
                NSLog("error: \(error)")
                completion(nil, error)
            }
        }
        
        
    }

}
