//
//  OverlayView.swift
//  TimeBit
//
//  Created by Anisha Jain on 5/12/17.
//  Copyright © 2017 BiteOfTime. All rights reserved.
//

import UIKit

class OverlayView: UIViewController {

    @IBOutlet weak var overlayImage: UIImageView!
    @IBOutlet weak var removerOverlayButton: UIButton!
    
    override func viewDidLoad() {
        overlayImage.layer.borderWidth = 2
        overlayImage.layer.borderColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.7).cgColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // When finished wait 10 seconds, than hide it
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func onRemove(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
    
