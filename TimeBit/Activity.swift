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
    
    var activity_id: String?
    var activity_name: String?
    var activity_desc: String?

    init(dictionary: NSDictionary) {
        activity_id = dictionary["activity_id"] as? String
        activity_name = dictionary["activity_name"] as? String
        activity_desc = dictionary["activity_desc"] as? String
    }
    
    init(pfobj: PFObject) {
        self.activity_id = pfobj["activity_id"] as? String
        self.activity_name = pfobj["activity_name"] as? String
        self.activity_desc = pfobj["activity_desc"] as? String
    }
    
    class func ActivitiesWithArray(dictionaries: [PFObject]) -> [Activity] {
        var activities = [Activity]()
        
        for pfobj in dictionaries {
            let activity = Activity(pfobj: pfobj)
            activities.append(activity)
        }
        return activities
    }

}
