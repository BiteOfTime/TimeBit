//
//  GoalsTableViewCell.swift
//  TimeBit
//
//  Created by Krishna Alex on 5/7/17.
//  Copyright © 2017 BiteOfTime. All rights reserved.
//

import UIKit

class GoalsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var activityNameLabel: UILabel!
    @IBOutlet weak var goalLabel: UILabel!
    @IBOutlet weak var activityImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        activityImage.layer.cornerRadius = 3
//        activityImage.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
