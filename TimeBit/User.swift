//
//  User.swift
//  TimeBit
//
//  Created by Krishna Alex on 4/26/17.
//  Copyright © 2017 BiteOfTime. All rights reserved.
//

import UIKit

class User: NSObject {
    static var userId: String? = UIDevice.current.identifierForVendor!.uuidString
    static var _currentUser: String?
    
    class var currentUser: String? {
        get {
            if _currentUser == nil {
                let defaults = UserDefaults.standard
                let userData = defaults.value(forKey: "userId")
                if let userData = userData {
                        _currentUser = userData as? String
                }
            }
            return _currentUser
        }
        set(user) {
            _currentUser = user
            let defaults = UserDefaults.standard
            
            if let user = user {
                defaults.set(user, forKey: "userId")
            } else {
                defaults.set(nil, forKey: "userId")
            }
            defaults.synchronize()
        }
    }
}
