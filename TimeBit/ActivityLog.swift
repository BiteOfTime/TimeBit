//
//  ActivityLog.swift
//  TimeBit
//
//  Created by Namrata Mehta on 4/29/17.
//  Copyright © 2017 BiteOfTime. All rights reserved.
//

import UIKit
import Parse

class ActivityLog: NSObject {
    
    var user_id: String?
    var activity_name: String?
    var activity_start_time: Date?
    var activity_end_time: Date?
    var activity_duration: Int64?
    var activity_event_date: String?
    
    init(dictionary: Dictionary<String, Any>) {
        user_id = dictionary["user_id"] as? String
        activity_name = dictionary["activity_name"] as? String
        activity_start_time = dictionary["activity_start_time"] as? Date
        activity_end_time = dictionary["activity_end_time"] as? Date
        activity_duration = dictionary["activity_duration"] as? Int64
        activity_event_date = dictionary["activity_event_date"] as? String
    }
    
    init(pfobj: PFObject) {
        self.user_id = pfobj["user_id"] as? String
        self.activity_name = pfobj["activity_name"] as? String
        self.activity_start_time = pfobj["activity_start_time"] as? Date
        self.activity_end_time = pfobj["activity_end_time"] as? Date
        self.activity_duration = pfobj["activity_duration"] as? Int64
        self.activity_event_date = pfobj["activity_event_date"] as? String
    }
    
    class func ActivityLogWithArray(dictionaries: [PFObject]) -> [ActivityLog] {
        var logActivity = [ActivityLog]()
        
        for pfobj in dictionaries {
            let activityLog = ActivityLog(pfobj: pfobj)
            logActivity.append(activityLog)
        }
        return logActivity
    }


}
