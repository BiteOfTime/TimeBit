//
//  AddNewActivityViewController.swift
//  TimeBit
//
//  Created by Krishna Alex on 4/30/17.
//  Copyright © 2017 BiteOfTime. All rights reserved.
//

import UIKit

@objc protocol AddNewActivityViewControllerDelegate {
    func addNewActivityViewController(onSaveActivity newActivity: Activity )
}

class AddNewActivityViewController: UIViewController, DefaultImagesPopoverDelegate {
    
    @IBOutlet weak var newActivityImage: UIButton!
    @IBOutlet var addNewActivityView: UIView!
    @IBOutlet weak var newActivityText: UITextField!
    @IBOutlet weak var newActivityDesc: UITextField!
    @IBOutlet weak var defaultImagesView: DefaultImagesPopover!
    @IBOutlet weak var selectButton: UIButton!
    var activity: Activity!
    var existingActivities: [Activity]!
    var newActivityNotExists = true

    weak var delegate: AddNewActivityViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        defaultImagesView.isHidden = true
        hidesBottomBarWhenPushed = false
        self.navigationItem.title = "Add New Activity"
        navigationController?.navigationBar.layer.shadowOffset = CGSize(width:0, height: 0)
        navigationController?.navigationBar.layer.shadowRadius = 3
        navigationController?.navigationBar.layer.shadowColor = UIColor.black.cgColor
        navigationController?.navigationBar.layer.shadowOpacity = 0.8
        
        selectButton.backgroundColor = UIColor(red: 16/255, green: 78/255, blue: 114/255, alpha: 1.0)
        selectButton.tintColor = .white
        selectButton.setImage(#imageLiteral(resourceName: "more"), for: .normal)
        selectButton.setImage(#imageLiteral(resourceName: "less"), for: .selected)
        
        newActivityImage.isUserInteractionEnabled = false
        defaultImagesView.delegate = self

        //addTapGesture()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapGesture(sender:)))
        selectButton.addGestureRecognizer(tapGesture)
    }
    
    func onTapGesture(sender: UITapGestureRecognizer) {
        if !defaultImagesView.isHidden {
            UIView.animate(withDuration: 0.4, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.defaultImagesView.alpha = 0.0
            }, completion: { finished in
                self.defaultImagesView.isHidden = true
            })
        }
    }

    func defaultImagesPopover(onSelect defaultImage: UIImage) {
        newActivityImage.setImage(defaultImage, for: .normal)
        newActivityImage.setImage(defaultImage, for: .selected)
        selectButton.isSelected = false
    }
    
    @IBAction func onSelectImage(_ sender: UIButton) {
        if defaultImagesView.isHidden {
            selectButton.isSelected = true
            self.defaultImagesView.isHidden = false
            self.defaultImagesView.alpha = 0.0
            UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.defaultImagesView.alpha = 1.0
            }, completion: nil)
        } else {
            selectButton.isSelected = false
            UIView.animate(withDuration: 0.4, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.defaultImagesView.alpha = 0.0
            }, completion: { finished in
                self.defaultImagesView.isHidden = true
            })
        }
        
    }
    
    @IBAction func onSaveActivityButton(_ sender: Any) {
        
        let newActivityName = self.newActivityText.text
        let newActivityDesc = self.newActivityDesc.text
        let newActivityImage = self.newActivityImage.imageView?.image

        if !(newActivityName?.isEmpty)! {
            
            //Check this new activity does not already exist
            ParseClient.sharedInstance.getActivities() { (activities: [Activity]?, error: Error?) -> Void in
                if error != nil {
                    NSLog("Error getting activities from Parse")
                } else {
                    NSLog("Items from Parse")
                    self.existingActivities = activities!
                    for activity in self.existingActivities {
                        // new activity already exists
                        if newActivityName?.lowercased() == activity.activityName?.lowercased() {
                            self.newActivityNotExists = false
                            break
                        }
                    }
                    if self.newActivityNotExists {
                        let newActivity = Activity(newActivityName!, newActivityDesc!, newActivityImage!)
                        ParseClient.sharedInstance.saveNewActivity(newActivity: newActivity as Activity?) { (PFObject, Error) -> () in
                            if Error != nil {
                                NSLog("Error saving to Parse")
                            } else {
                                NSLog("Saved activity to Parse")
                                //let newActivity = Activity(activityName!, activityDesc!, #imageLiteral(resourceName: "Eat"))
                                self.delegate?.addNewActivityViewController(onSaveActivity: newActivity)
                                self.navigationController?.popViewController(animated: true)
                            }
                        }
                        
                    } else {
                        let alert = UIAlertController(title: "TimeBit",
                                                      message: "This activity already exists",
                                                      preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "Ok", style: .default, handler: { (action) -> Void in
                            print("OK")
                        })
                        alert.addAction(okAction)
                        self.newActivityNotExists = true
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
            
        } else {
            let alert = UIAlertController(title: "TimeBit",
                                          message: "Activity Name can't be empty",
                preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: { (action) -> Void in
                print("OK")
            })
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
    }
}

