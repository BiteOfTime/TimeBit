//
//  DetailActivity1Cell.swift
//  TimeBit
//
//  Created by Namrata Mehta on 4/29/17.
//  Copyright © 2017 BiteOfTime. All rights reserved.
//

import UIKit

class DetailActivity1Cell: UITableViewCell {

    @IBOutlet weak var dailyCount: UILabel!
    @IBOutlet weak var weeklyCount: UILabel!
    @IBOutlet weak var sinceCreationCount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    
    
}
