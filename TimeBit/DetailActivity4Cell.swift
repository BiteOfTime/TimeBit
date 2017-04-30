//
//  DetailActivity4Cell.swift
//  TimeBit
//
//  Created by Namrata Mehta on 4/29/17.
//  Copyright © 2017 BiteOfTime. All rights reserved.
//

import UIKit

@objc protocol DetailActivity4CellDelegate {
    @objc optional func detailActivity4Cell(detailActivity4Cell:DetailActivity4Cell, didChangeValue value: Bool)
}

class DetailActivity4Cell: UITableViewCell {

    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var minuteLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    
    weak var delegate: DetailActivity4CellDelegate?
    var activity_name: String!
    
    var startActivity: Bool = false
    var isActivityRunning: Bool = false
    var isActivityPaused: Bool = false
    var passedSeconds: Int = 0
    var startDate: Date?
    var quitDate: Date?
    var activityTimer: Timer?
    var totalduration: NSInteger = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    @IBAction func onButtonClick(_ sender: Any) {
        print("Button is clicked before \(startActivity)")
        startActivity = !startActivity
        if(startActivity) {
            startButton.setTitle("Stop Activity", for: UIControlState())
            startDate = Date()
            passedSeconds = 0
            invalidateTimer()
            startActivityTimer()
        } else {
            startButton.setTitle("Start Activity", for: UIControlState())
            invalidateTimer()
            isActivityRunning = false
            minuteLabel.text = "00"
            hourLabel.text = "00"
            secondLabel.text = "00"
            
            var currentDate = formatDate(dateString: String(describing: Date()))
            print("currentDate is \(currentDate)")
            
            print("Saving the activity in db")
            print("startDate \(startDate)")
            print("endDate \(Date())")
            print("duration \(passedSeconds)")
            
            if (!activity_name.isEmpty) {
                let params = ["activity_name": activity_name, "activity_start_time": startDate!, "activity_end_time": Date(), "activity_duration": passedSeconds, "activity_event_date": currentDate] as [String : Any]
                ParseClient.sharedInstance.saveActivityLog(params: params as NSDictionary?) { (PFObject, Error) -> () in
                    if Error != nil {
                        NSLog("Error saving to the log for the activity \(self.activity_name)")
                    } else {
                        NSLog("Saved the activity for \(self.activity_name)")
                    }
                }
            }
            
            startDate = nil
            passedSeconds = 0
            UserDefaults.standard.set(isActivityRunning, forKey:"quitActivityRunning")
            UserDefaults.standard.synchronize()
        }
        print("Button is clicked after \(startActivity)")
        delegate?.detailActivity4Cell?(detailActivity4Cell: self, didChangeValue: startActivity)
    }
    
    
    func invalidateTimer() {
        if let timer = activityTimer {
            timer.invalidate()
        }
    }
    
    func startActivityTimer() {
        activityTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(DetailActivity4Cell.updateLabel), userInfo: nil, repeats: true)
    }
    
    func updateLabel() {
        passedSeconds += 1
        
        let second = passedSeconds % 60
        let minutes = (passedSeconds / 60) % 60
        let hours = passedSeconds / 3600
        
        secondLabel.text = String(second)
        minuteLabel.text = String(minutes)
        hourLabel.text = String(hours)
    }
    
    func formatDate(dateString: String) -> String? {
        
        let formatter = DateFormatter()
        let currentDateFormat = DateFormatter.dateFormat(fromTemplate: "MMddyyyy", options: 0, locale: NSLocale(localeIdentifier: "en-GB") as Locale)
        
        formatter.dateFormat = currentDateFormat
        let formattedDate = formatter.string(from: Date())
        // gbSwiftDayString now contains the string "02/06/2014".
        
        return formattedDate
    }
    
}
