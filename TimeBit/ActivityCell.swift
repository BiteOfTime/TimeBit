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
    //func activityCell(onStartStop activityCell: ActivityCell)
    func activityCell(onDeleteActivity activityCell: ActivityCell)
}

class ActivityCell: UICollectionViewCell {
    
    @IBOutlet weak var activityCellView: UIView!
    //@IBOutlet weak var activityImage: UIButton!
    @IBOutlet weak var activityNameLabel: UILabel!
    @IBOutlet weak var timeSpentLabel: UILabel!
    @IBOutlet weak var deleteActivityButton: UIButton!
    @IBOutlet weak var activityImageView: UIView!
    @IBOutlet weak var activityImage: UIImageView!
    
    weak var delegate: ActivityCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        activityImageView.layer.cornerRadius = 0.5 * activityImageView.bounds.size.width
        deleteActivityButton.isHidden = true
    }
    
//    @IBAction func onActivityImage(_ sender: Any) {
//        delegate?.activityCell(onStartStop: self)
//    }
    
    @IBAction func onDeleteActivity(_ sender: Any) {
        delegate?.activityCell(onDeleteActivity: self)
    }

}
