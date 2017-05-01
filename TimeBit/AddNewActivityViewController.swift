//
//  AddNewActivityViewController.swift
//  TimeBit
//
//  Created by Krishna Alex on 4/30/17.
//  Copyright © 2017 BiteOfTime. All rights reserved.
//

import UIKit

class AddNewActivityViewController: UIViewController {
    @IBOutlet weak var newActivityText: UITextField!
    @IBOutlet weak var newActivityDesc: UITextField!
    
    var activity: Activity!
    var activities: [Activity]!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Add New Activity"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onSaveActivityButton(_ sender: Any) {
        
        let acivityName = newActivityText.text
        let activityDesc = newActivityDesc.text
//        let activityImage = textToImage(drawText: acivityName! as NSString, inImage: UIImage(#imageLiteral(resourceName: "RoundEmptyCircle"))!, atPoint: CGPoint(x: 20, y: 20))
//
        if !(acivityName?.isEmpty)! {
            let params = ["activityName": acivityName!, "activityDesc": activityDesc!] as [String : Any]
            ParseClient.sharedInstance.saveNewActivity(params: params as NSDictionary?) { (PFObject, Error) -> () in
                if Error != nil {
                    NSLog("Error saving to Parse")
                } else {
                    NSLog("Saved activity to Parse")
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
//    func textToImage(drawText text: NSString, inImage image: UIImage, atPoint point: CGPoint) -> UIImage {
//        let textColor = UIColor.white
//        let textFont = UIFont(name: "Helvetica Bold", size: 12)!
//        
//        let scale = UIScreen.main.scale
//        UIGraphicsBeginImageContextWithOptions(image.size, false, scale)
//        
//        let textFontAttributes = [
//            NSFontAttributeName: textFont,
//            NSForegroundColorAttributeName: textColor,
//            ] as [String : Any]
//        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
//        
//        let rect = CGRect(origin: point, size: image.size)
//        text.draw(in: rect, withAttributes: textFontAttributes)
//        
//        let newImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        
//        return newImage!
//    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
