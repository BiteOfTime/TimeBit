//
//  DefaultImagesCell.swift
//  TimeBit
//
//  Created by Anisha Jain on 5/7/17.
//  Copyright © 2017 BiteOfTime. All rights reserved.
//

import UIKit

class DefaultImagesCell: UICollectionViewCell {
    
    
    @IBOutlet weak var defaultImage: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()

        defaultImage.layer.cornerRadius = 0.2 * defaultImage.bounds.size.width
        defaultImage.contentEdgeInsets = UIEdgeInsetsMake(2,2,2,2)
    }
}
