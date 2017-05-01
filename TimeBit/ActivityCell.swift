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
}

class ActivityCell: UICollectionViewCell {
    
    @IBOutlet weak var activityCellView: UIView!
    @IBOutlet weak var activityImage: UIButton!
    @IBOutlet weak var activityNameLabel: UILabel!
    @IBOutlet weak var timeSpentLabel: UILabel!
    
    weak var delegate: ActivityCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        activityImage.layer.cornerRadius = 0.5 * activityImage.bounds.size.width
        activityImage.clipsToBounds = true
        //activityCellView.backgroundColor = UIColor(red: 9/255, green: 37/255, blue: 62/255, alpha: 1.0)
    }
    
    @IBAction func onActivityImage(_ sender: Any) {
        delegate?.activityCell(onStartStop: self)
    }
    
    override var isSelected: Bool {
        didSet {
            if (isSelected) {
                activityImage.backgroundColor = UIColor(red: 10/255, green: 204/255, blue: 247/255, alpha: 1.0)
                activityImage.tintColor = .white
            } else {
                activityImage.backgroundColor = UIColor(red: 255/255, green: 55/255, blue: 96/255, alpha: 1.0)
                activityImage.tintColor = .white
            }
        }
    }

}
