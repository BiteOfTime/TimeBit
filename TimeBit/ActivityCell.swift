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
    func activityCell(onStartActivity activityCell: ActivityCell)
    func activityCell(onStopActivity activityCell: ActivityCell)
}

class ActivityCell: UICollectionViewCell {
    
    @IBOutlet weak var activityCellView: UIView!
    @IBOutlet weak var activityImage: UIButton!
    //@IBOutlet weak var activityImageView: PFImageView!
    @IBOutlet weak var activityNameLabel: UILabel!
    @IBOutlet weak var timeSpentLabel: UILabel!
    
    weak var delegate: ActivityCellDelegate?
    var activityRunning: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        activityCellView.backgroundColor = UIColor(red: 9/255, green: 37/255, blue: 62/255, alpha: 1.0)
        //activityCellView.f
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapImage(_:)))
//        activityImageView.isUserInteractionEnabled = true
//        activityImageView.addGestureRecognizer(tapGesture)
    }
    
    @IBAction func onActivityImage(_ sender: Any) {
        activityImage.isSelected = !(activityImage.isSelected)
        if ( activityImage.isSelected && !activityRunning ){
            print("Timer started")
            activityImage.backgroundColor = .blue
            activityImage.tintColor = .white
            activityRunning = true
            //activityImage.im
            delegate?.activityCell(onStartActivity: self)
        } else {
            print("Timer stopped")
            activityImage.backgroundColor = .red
            activityImage.tintColor = .white
            activityRunning = false
            delegate?.activityCell(onStopActivity: self)
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
