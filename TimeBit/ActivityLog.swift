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
    
    class func getTimeSpentToday(activityLog: [ActivityLog]?) -> String {
        if(activityLog == nil || activityLog?.count == 0) {
            return "0 Second"
        }
        let currentDate = Utils.formatDate(dateString: String(describing: Date()))
        var totalTimeSpentToday: Int64 = 0
        for log in activityLog! {
            if (log.activity_duration != nil && log.activity_event_date == currentDate) {
                totalTimeSpentToday += Int64(log.activity_duration!)
            }
        }
        
        return getTimeCount(duration: totalTimeSpentToday)
    }
    
    class func getTimeSpentPastSevenDay(activityLog: [ActivityLog]?) -> String {
        if(activityLog == nil || activityLog?.count == 0) {
            return "0 Second"
        }
        var totalTimeSpentSevenDay: Int64 = 0
        
        /*
        for log in activityLog! {
            if log.activity_duration != nil {
                totalTimeSpentSevenDay += Int64(log.activity_duration!)
            }
        }
        */
        
        var weekDateRange = self.getPastDates(days: 7)
        activityLog?.forEach { x in
            if(weekDateRange.contains(x.activity_event_date)) {
                totalTimeSpentSevenDay += Int64(x.activity_duration!)
            }
        }
        
        return getTimeCount(duration: totalTimeSpentSevenDay)
    }
    
    class func getTimeSpentTillNow(activityLog: [ActivityLog]?) -> String {
        if(activityLog == nil || activityLog?.count == 0) {
            return "0 Second"
        }
        var totalTimeSpentTillNow: Int64 = 0
        
        for log in activityLog! {
            if (log.activity_duration != nil) {
                totalTimeSpentTillNow += Int64(log.activity_duration!)
            }
        }
        
        return getTimeCount(duration: totalTimeSpentTillNow)
    }

    class func getTimeCount(duration: Int64) -> String {
        let seconds = duration % 60
        let minutes = duration / 60
        let hours = duration / 3600
        
        if hours > 0 {
            return minutes > 0 ? "\((Double(hours) + (Double(minutes)) / 60.0).roundto(places: 1)) Hours" : "\(hours) Hours"
        }
        
        if minutes > 0 {
            return seconds > 0 ? "\((Double(minutes) + (Double(seconds)) / 60.0).roundto(places: 1)) Minutes" : "\(minutes) Minutes"
        }
        
        return "\(seconds) Seconds"
    }
    
    class func getPastDates(days: Int) -> NSArray {
        let cal = NSCalendar.current
        var today = cal.startOfDay(for: Date())
        var arrayDate = [String]()
        
        for i in 1 ... days {
            let day = cal.component(.day, from: today)
            let month = cal.component(.month, from: today)
            let year = cal.component(.year, from: today)
            
            var dayInString: String = "00"
            var monthInString: String = "00"
            if day <= 9 {
                dayInString = "0"+String(day)
            } else {
                dayInString = String(day)
            }
            if month <= 9 {
                monthInString = "0"+String(month)
            } else {
                monthInString = String(month)
            }
            
            arrayDate.append(dayInString + "/" + monthInString+"/" + String(year))
            // move back in time by one day:
            today = cal.date(byAdding: .day, value: -1, to: today)!
        }
        return arrayDate as NSArray
    }

}

extension Double {
    /// Rounds the double to decimal places value
    func roundto(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}


