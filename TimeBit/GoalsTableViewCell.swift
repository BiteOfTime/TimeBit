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
    @IBOutlet weak var imageUIView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageUIView?.layer.cornerRadius = 0.5 * imageUIView.bounds.size.width
        activityImage?.tintColor = .white
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
