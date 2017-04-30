//
//  ActivityCell.swift
//  TimeBit
//
//  Created by Anisha Jain on 4/28/17.
//  Copyright © 2017 BiteOfTime. All rights reserved.
//

import UIKit
import ParseUI

@objc protocol ActivityCellDelegate {
    func activityCell(onPanGesture activityCell: ActivityCell)
}

class ActivityCell: UICollectionViewCell {
    
    @IBOutlet weak var activityCellView: UIView!
    @IBOutlet weak var activityImageView: PFImageView!
    @IBOutlet weak var activityNameLabel: UILabel!
    @IBOutlet weak var timeSpentLabel: UILabel!
    
    weak var delegate: ActivityCellDelegate?
    
//    @IBAction func onPanGesture(_ sender: UIPanGestureRecognizer) {
//        delegate?.activityCell(onPanGesture: self)
//    }
}
