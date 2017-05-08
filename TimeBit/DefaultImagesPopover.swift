//
//  DefaultImagesPopover.swift
//  TimeBit
//
//  Created by Anisha Jain on 5/7/17.
//  Copyright © 2017 BiteOfTime. All rights reserved.
//

import UIKit
@objc protocol DefaultImagesPopoverDelegate {
    func defaultImagesPopover(onSelect defaultImage: UIImage)
}

class DefaultImagesPopover: UIView, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    weak var delegate: DefaultImagesPopoverDelegate?
    var defaultImages: [UIImage]?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubViews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubViews()
    }
    
    func initSubViews() {
        let nib = UINib(nibName: "DefaultImagesPopover", bundle: nil)
        nib.instantiate(withOwner: self, options: nil)
        
        contentView.frame = bounds
        addSubview(contentView)
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.darkGray.cgColor
        
        collectionView.register(UINib(nibName: "DefaultImagesCell", bundle: nil), forCellWithReuseIdentifier: "DefaultImagesCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsSelection = true
        defaultImages = [#imageLiteral(resourceName: "baseball"), #imageLiteral(resourceName: "bike"), #imageLiteral(resourceName: "bus"), #imageLiteral(resourceName: "car"), #imageLiteral(resourceName: "cart"), #imageLiteral(resourceName: "cricket"), #imageLiteral(resourceName: "flight"), #imageLiteral(resourceName: "football"), #imageLiteral(resourceName: "gaming"), #imageLiteral(resourceName: "garden"), #imageLiteral(resourceName: "hockey"), #imageLiteral(resourceName: "paint"), #imageLiteral(resourceName: "phone"), #imageLiteral(resourceName: "sail"), #imageLiteral(resourceName: "soccer"), #imageLiteral(resourceName: "swimming"), #imageLiteral(resourceName: "tools"), #imageLiteral(resourceName: "train")]
    }
    
    
    func changeColorOfCell(defaultImagesCell: DefaultImagesCell, index: Int) {
        let mod = index % 6
        switch mod {
        case 0:
            // blue
            defaultImagesCell.defaultImage.backgroundColor = UIColor(red: 255/255, green: 55/255, blue: 96/255, alpha: 1.0)
        case 1:
            // red
            defaultImagesCell.defaultImage.backgroundColor = UIColor(red: 10/255, green: 204/255, blue: 247/255, alpha: 1.0)
        case 2:
            // yellow
            defaultImagesCell.defaultImage.backgroundColor = UIColor(red: 255/255, green: 223/255, blue: 0/255, alpha: 1.0)
        case 3:
            // green
            defaultImagesCell.defaultImage.backgroundColor = UIColor(red: 66/255, green: 188/255, blue: 88/255, alpha: 1.0)
        case 4:
            //purple
            defaultImagesCell.defaultImage.backgroundColor = UIColor(red: 196/255, green: 44/255, blue: 196/255, alpha: 1.0)
        default:
            //orange
            defaultImagesCell.defaultImage.backgroundColor = UIColor(red: 232/255, green: 134/255, blue: 3/255, alpha: 1.0)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (defaultImages?.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DefaultImagesCell", for: indexPath) as! DefaultImagesCell
        
        let defaultImage = defaultImages?[indexPath.row]
        cell.defaultImage.setImage(defaultImage, for: .normal)
        cell.defaultImage.setImage(defaultImage, for: .selected)
        cell.defaultImage.isUserInteractionEnabled = false
        changeColorOfCell(defaultImagesCell: cell, index: indexPath.row)
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let defaultImageCell = collectionView.cellForItem(at: indexPath) as! DefaultImagesCell
        let defaultImage =  defaultImageCell.defaultImage.imageView?.image
        delegate?.defaultImagesPopover(onSelect: defaultImage!)
        isHidden = true
    }
}
