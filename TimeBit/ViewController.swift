//
//  ViewController.swift
//  TimeBit
//
//  Created by Krishna Alex on 4/24/17.
//  Copyright © 2017 BiteOfTime. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController {

    @IBOutlet weak var newActivityText: UITextField!
    @IBOutlet weak var newActivityDesc: UITextField!
    
    var activity: Activity!
    var activities: [Activity]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func onSaveActivityButton(_ sender: Any) {
        
        let acivityName = newActivityText.text
        let activityDesc = newActivityDesc.text
        
        if !(acivityName?.isEmpty)! {
            let params = ["activityName": acivityName!, "activityDesc": activityDesc!] as [String : Any]
            ParseClient.sharedInstance.saveNewActivity(params: params as NSDictionary?) { (PFObject, Error) -> () in
                if Error != nil {
                    NSLog("Error saving to Parse")
                } else {
                    NSLog("Saved activity to Parse")
                }
            }
        }
    }
    

    @IBAction func onGetActivityButton(_ sender: Any) {
        ParseClient.sharedInstance.getActivities() { (activities: [Activity]?, error: Error?) -> Void in
            if error != nil {
                NSLog("Error getting activities from Parse")
            } else {
                self.activities = activities!
                NSLog("Items from Parse")
            }
        }
        
    }

}

