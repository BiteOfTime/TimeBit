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
    
    override func viewWillAppear(_ animated: Bool) {
        // When finished wait 10 seconds, than hide it
        DispatchQueue.main.asyncAfter(deadline: .now() + 60.0) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func onTap(_ sender: UITapGestureRecognizer) {
        print("tapped")
        self.dismiss(animated: true, completion: nil)
    }
    
}
    
