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
//    func activityCell(onStartActivity activityCell: ActivityCell)
//    func activityCell(onStopActivity activityCell: ActivityCell)
    func activityCell(onStartStop activityCell: ActivityCell)
}

class ActivityCell: UICollectionViewCell {
    
    @IBOutlet weak var activityCellView: UIView!
    @IBOutlet weak var activityImage: UIButton!
    //@IBOutlet weak var activityImageView: PFImageView!
    @IBOutlet weak var activityNameLabel: UILabel!
    @IBOutlet weak var timeSpentLabel: UILabel!
    
    weak var delegate: ActivityCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //activityCellView.backgroundColor = UIColor(red: 9/255, green: 37/255, blue: 62/255, alpha: 1.0)
    }
    
    @IBAction func onActivityImage(_ sender: Any) {
        delegate?.activityCell(onStartStop: self)
    }
    
    override var isSelected: Bool {
        didSet {
            if (isSelected) {
                activityImage.backgroundColor = .blue
                activityImage.tintColor = .white
            } else {
                activityImage.backgroundColor = .red
                activityImage.tintColor = .white
            }
        }
    }
    
    
//    func onTapImage(_ sender: UITapGestureRecognizer) {
//        print("on tapping")
//        delegate?.activityCell(onTapGesture: self)
//    }
//    @IBAction func onPanGesture(_ sender: UIPanGestureRecognizer) {
//        delegate?.activityCell(onPanGesture: self)
//    }
}
