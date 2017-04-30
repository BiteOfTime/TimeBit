//
//  Activity.swift
//  TimeBit
//
//  Created by Krishna Alex on 4/25/17.
//  Copyright © 2017 BiteOfTime. All rights reserved.
//

import UIKit
import Parse

class Activity: NSObject {
    
    var userId: String?
    var activityName: String?
    var activityDescription: String?
    var activityImage: PFFile?
    
    
    init(dictionary: NSDictionary) {
        userId = dictionary["user_id"] as? String
        activityName = dictionary["activity_name"] as? String
        activityDescription = dictionary["activity_desc"] as? String
    }
    
    init(_ activityName: String, _ activityDescription: String, _ activityImage: PFFile?) {
        self.activityName = activityName
        self.activityDescription = activityDescription
        self.activityImage = activityImage
    }
    
    init(pfobj: PFObject) {
        self.userId = pfobj["user_id"] as? String
        self.activityName = pfobj["activity_name"] as? String
        self.activityDescription = pfobj["activity_desc"] as? String
        self.activityImage = pfobj["activity_image"] as? PFFile
    }
    
    class func ActivitiesWithArray(dictionaries: [PFObject]) -> [Activity] {
        var activities = [Activity]()
        
        for pfobj in dictionaries {
            
            let activity = Activity(pfobj: pfobj)
            print("activity here....", activity)
            activities.append(activity)
        }
        return activities
    }

}
