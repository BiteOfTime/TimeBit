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
        
        // Create Parse object PFObject
        let activityObject = PFObject(className: "ActivityTest")
        
        // Add relevant fields to the object
        activityObject["activity_name"] = acivityName
        activityObject["activity_desc"] = activityDesc
        
        activityObject.saveInBackground { (success: Bool, error: Error?) in
            if (success) {
                print("Saved activity")
            } else {
                print(" There was a problem, check error.description", error?.localizedDescription as Any)
            }
            
        }
        newActivityText.text = ""
        newActivityDesc.text = ""
    }
    

    @IBAction func onGetActivityButton(_ sender: Any) {
        var query = PFQuery(className:"ActivityTest")
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) scores.")
                // Do something with the found objects
                if let objects = objects {
                    for object in objects {
                        print(object)
                    }
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.localizedDescription)")
            }
            
        }
    }

}

