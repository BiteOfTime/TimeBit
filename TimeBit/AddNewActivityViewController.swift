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

class AddNewActivityViewController: UIViewController, UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newActivityImage: UIButton!
    @IBOutlet var addNewActivityView: UIView!
    @IBOutlet weak var newActivityDesc: UITextView!
    @IBOutlet weak var newActivityText: UITextField!
    @IBOutlet weak var selectButton: UIButton!
    var activity: Activity!
    var existingActivities: [Activity]!
    var newActivityNotExists = true
    var defaultImages: [UIImage]?
    
    weak var delegate: AddNewActivityViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        newActivityText.delegate = self
        newActivityText.becomeFirstResponder()

        collectionView.register(UINib(nibName: "DefaultImagesCell", bundle: nil), forCellWithReuseIdentifier: "DefaultImagesCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsSelection = true
        collectionView.layer.shadowColor = UIColor(red: 2/255, green: 11/255, blue: 23/255, alpha: 1.0).cgColor
        collectionView.layer.shadowOpacity = 1.0
        collectionView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        collectionView.layer.shadowRadius = 20
        collectionView.layer.cornerRadius = 4
        
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = gradientView.bounds
        gradient.colors = [UIColor(red: 3/255, green: 21/255, blue:45/255, alpha: 1.0).cgColor, UIColor(red: 8/255, green: 28/255, blue: 55/255, alpha: 1.0).cgColor]

        gradient.startPoint = CGPoint(x: 0, y: 1)
        gradient.endPoint = CGPoint(x: 0, y: 0)
        gradientView.layer.insertSublayer(gradient, at: 0)
        //view.layer.insertSublayer(gradientView.layer, at: 0)
        
        defaultImages = [#imageLiteral(resourceName: "baseball"), #imageLiteral(resourceName: "bike"), #imageLiteral(resourceName: "bus"), #imageLiteral(resourceName: "car"), #imageLiteral(resourceName: "cart"), #imageLiteral(resourceName: "cricket"), #imageLiteral(resourceName: "flight"), #imageLiteral(resourceName: "football"), #imageLiteral(resourceName: "gaming"), #imageLiteral(resourceName: "garden"), #imageLiteral(resourceName: "hockey"), #imageLiteral(resourceName: "paint"), #imageLiteral(resourceName: "phone"), #imageLiteral(resourceName: "sail"), #imageLiteral(resourceName: "soccer"), #imageLiteral(resourceName: "swimming"), #imageLiteral(resourceName: "tools"), #imageLiteral(resourceName: "train")]
        
        newActivityDesc.layer.cornerRadius = 4
    
        hidesBottomBarWhenPushed = false
        self.navigationItem.title = "Add Activity"
        navigationController?.navigationBar.layer.shadowOffset = CGSize(width:0, height: 0)
        navigationController?.navigationBar.layer.shadowRadius = 3
        navigationController?.navigationBar.layer.shadowColor = UIColor.black.cgColor
        navigationController?.navigationBar.layer.shadowOpacity = 0.8
        
        selectButton.tintColor = .white
        selectButton.setImage(#imageLiteral(resourceName: "more"), for: .normal)
        selectButton.setImage(#imageLiteral(resourceName: "less"), for: .selected)
        
        newActivityImage.isUserInteractionEnabled = false
        let saveButton : UIBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.plain, target: self, action: #selector(onSaveActivityButton))
        
        self.navigationItem.rightBarButtonItem =  saveButton

        //addTapGesture()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Called when the user click on the view (outside the UITextField).
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapGesture(sender:)))
        selectButton.addGestureRecognizer(tapGesture)
    }
    
    func onTapGesture(sender: UITapGestureRecognizer) {
        if !collectionView.isHidden {
            UIView.animate(withDuration: 0.4, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.collectionView.alpha = 0.0
            }, completion: { finished in
                self.collectionView.isHidden = true
            })
        }
    }
    
    @IBAction func onSelectImage(_ sender: UIButton) {
        if collectionView.isHidden {
            selectButton.isSelected = true
            self.collectionView.isHidden = false
            self.collectionView.alpha = 0.0
            UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.collectionView.alpha = 1.0
            }, completion: nil)
        } else {
            selectButton.isSelected = false
            UIView.animate(withDuration: 0.4, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.collectionView.alpha = 0.0
            }, completion: { finished in
                self.collectionView.isHidden = true
            })
        }
        
    }
    
    func onSaveActivityButton() {
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 32, height: 32);
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let defaultImageCell = collectionView.cellForItem(at: indexPath) as! DefaultImagesCell
        let defaultImage =  defaultImageCell.defaultImage.imageView?.image
        //delegate?.defaultImagesPopover(onSelect: defaultImage!)
        newActivityImage.setImage(defaultImage, for: .normal)
        newActivityImage.setImage(defaultImage, for: .selected)
        selectButton.isSelected = false
        collectionView.isHidden = true
    }

}

