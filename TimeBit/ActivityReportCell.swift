//
//  ActivityReportCell.swift
//  TimeBit
//
//  Created by Namrata Mehta on 5/7/17.
//  Copyright © 2017 BiteOfTime. All rights reserved.
//

import UIKit

class ActivityReportCell: UITableViewCell {

    @IBOutlet weak var activityNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var activityImageView: UIImageView!
    @IBOutlet weak var timespentTillNowLabel: UILabel!
    @IBOutlet weak var timespentInSevenDaysLabel: UILabel!
    @IBOutlet weak var timespentTodayLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    /*
 
     @IBOutlet weak var descriptionLabel: UILabel!
     @IBOutlet weak var timespentTillNowLabel: UILabel!
     @IBOutlet weak var timespentInSevenDaysLabel: UILabel!
     @IBOutlet weak var timespentTodayLabel: UILabel!
     @IBOutlet weak var activityImageView: UIImageView!
     @IBOutlet weak var activityNameLabel: UILabel!
 
 */
    
}
