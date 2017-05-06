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
    func activityCell(onStartStop activityCell: ActivityCell)
    func activityCell(onDeleteActivity activityCell: ActivityCell)
}

class ActivityCell: UICollectionViewCell {
    
    @IBOutlet weak var activityCellView: UIView!
    @IBOutlet weak var activityImage: UIButton!
    @IBOutlet weak var activityNameLabel: UILabel!
    @IBOutlet weak var timeSpentLabel: UILabel!
    @IBOutlet weak var deleteActivityButton: UIButton!
    
    weak var delegate: ActivityCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        activityImage.layer.cornerRadius = 0.5 * activityImage.bounds.size.width
        activityImage.clipsToBounds = true
        deleteActivityButton.isHidden = true
        activityImage.contentEdgeInsets = UIEdgeInsetsMake(6,6,6,6)
    }
    
    @IBAction func onActivityImage(_ sender: Any) {
        delegate?.activityCell(onStartStop: self)
    }
    
    @IBAction func onDeleteActivity(_ sender: Any) {
        delegate?.activityCell(onDeleteActivity: self)
    }

}
