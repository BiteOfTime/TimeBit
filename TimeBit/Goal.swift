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
    var hours: Int? // 1 - 24 hrs
    var mins: Int? //  1 - 60 mins
    var frequency: String? //today, daily, weekly or monthly
    
    init(dictionary: NSDictionary) {
        userId = dictionary["user_id"] as? String
        activityName = dictionary["activity_name"] as? String
        limit = dictionary["limit"] as? String
        hours = dictionary["limit"] as? Int
        mins = dictionary["limit"] as? Int
        frequency = dictionary["limit"] as? String
    }
    
    init(pfobj: PFObject) {
        self.userId = pfobj["user_id"] as? String
        self.activityName = pfobj["activity_name"] as? String
        self.limit = pfobj["limit"] as? String
        self.hours = Int(pfobj["hours"]! as? String ?? "") ?? 0
        self.mins = Int(pfobj["mins"]! as? String ?? "") ?? 0
        self.frequency = pfobj["frequency"] as? String
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

