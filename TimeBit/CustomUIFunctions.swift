//
//  CustomUIFunctions.swift
//  TimeBit
//
//  Created by Krishna Alex on 5/13/17.
//  Copyright © 2017 BiteOfTime. All rights reserved.
//

import Foundation


import UIKit
    
final class CustomUIFunctions {
    
    private static let lineColor = UIColor(displayP3Red: 0.18, green: 0.23, blue: 0.30, alpha: 1.0).cgColor
    private static let lineWidth: CGFloat = 0.5
    
    class func getlineColor() -> CGColor {
        return CustomUIFunctions.lineColor
    }
    
    class func getlineWidth() -> CGFloat {
        return CustomUIFunctions.lineWidth
    }

    
    class func imageBackgroundColor(index: Int) -> UIColor {
        let mod = index % 6
        let backgroundColor: UIColor!
        switch mod {
        case 0:
            // blue
            backgroundColor = UIColor(red: 255/255, green: 55/255, blue: 96/255, alpha: 1.0)
        case 1:
            // red
            backgroundColor = UIColor(red: 10/255, green: 204/255, blue: 247/255, alpha: 1.0)
        case 2:
            // yellow
            backgroundColor = UIColor(red: 255/255, green: 223/255, blue: 0/255, alpha: 1.0)
        case 3:
            // green
            backgroundColor = UIColor(red: 66/255, green: 188/255, blue: 88/255, alpha: 1.0)
        case 4:
            //purple
            backgroundColor = UIColor(red: 196/255, green: 44/255, blue: 196/255, alpha: 1.0)
        default:
            //orange
            backgroundColor = UIColor(red: 232/255, green: 134/255, blue: 3/255, alpha: 1.0)
        }
        return backgroundColor
    }

    
}
