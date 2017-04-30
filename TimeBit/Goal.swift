//
//  Goal.swift
//  TimeBit
//
//  Created by Krishna Alex on 4/28/17.
//  Copyright © 2017 BiteOfTime. All rights reserved.
//

import UIKit
import Parse

class Goal: NSObject {
    
    var userId : String?
    var activityName : String?
    var limit: String? //equal, atleast or atmax
    var frequency: String? //today, daily, weekly or monthly
    var hours: Int? // 1 - 24 hrs
    var mins: Int? //  1 - 60 mins
    
//    init(dictionary: NSDictionary) {
//        user_id = dictionary["user_id"] as? String
//        activity_name = dictionary["activity_name"] as? String
//        activity_desc = dictionary["activity_desc"] as? String
//    }
    
    init(pfobj: PFObject) {
        self.userId = pfobj["user_id"] as? String
        self.activityName = pfobj["activity_name"] as? String
        self.limit = pfobj["limit"] as? String
        self.frequency = pfobj["frequency"] as? String
        self.hours = pfobj["hours"] as? Int
        self.mins = pfobj["mins"] as? Int
    }
    
    class func GoalsWithArray(dictionaries: [PFObject]) -> [Goal] {
        var goals = [Goal]()
        
        for pfobj in dictionaries {
            let goal = Goal(pfobj: pfobj)
            goals.append(goal)
        }
        return goals
    }
    
}

