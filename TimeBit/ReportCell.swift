//
//  ReportCell.swift
//  TimeBit
//
//  Created by Namrata Mehta on 5/2/17.
//  Copyright © 2017 BiteOfTime. All rights reserved.
//

import UIKit

class ReportCell: UITableViewCell {

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var timespentTillNowLabel: UILabel!
    @IBOutlet weak var timespentInSevenDaysLabel: UILabel!
    @IBOutlet weak var timespentTodayLabel: UILabel!
    @IBOutlet weak var activityImageView: UIImageView!
    @IBOutlet weak var activityNameLabel: UILabel!
    
    var activities: [Activity] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
