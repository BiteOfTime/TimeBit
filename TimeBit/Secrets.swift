//
//  Activity.swift
//  TimeBit
//
//  Created by Krishna Alex on 4/25/17.
//  Copyright © 2017 BiteOfTime. All rights reserved.
//

import UIKit

final class Secrets {
    //Replace with your parse application id
    private static let applicationId = ""
    //Replace with your parse client key
    private static let clientKey = ""
    //Replace with your parse server
    private static let server = ""
    
    class func getApplicationId() -> String {
        return Secrets.applicationId
    }
    class func getClientKey() -> String {
        return Secrets.clientKey
    }
    class func getServer() -> String {
        return Secrets.server
    }
    
}


