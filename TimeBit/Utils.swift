//
//  uitils.swift
//  TimeBit
//
//  Created by Anisha Jain on 4/30/17.
//  Copyright © 2017 BiteOfTime. All rights reserved.
//

import Foundation

class Utils {
    
    class func formatDate(dateString: String) -> String? {
        
        let formatter = DateFormatter()
        let currentDateFormat = DateFormatter.dateFormat(fromTemplate: "MMddyyyy", options: 0, locale: NSLocale(localeIdentifier: "en-GB") as Locale)
        
        formatter.dateFormat = currentDateFormat
        let formattedDate = formatter.string(from: Date())
        // contains the string "22/06/2014".
        
        return formattedDate
    }
    
    
}
