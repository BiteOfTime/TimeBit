//
//  TimerView.swift
//  TimeBit
//
//  Created by Anisha Jain on 4/28/17.
//  Copyright © 2017 BiteOfTime. All rights reserved.
//

import UIKit

@objc protocol TimerViewDeleagte {
    func timerView(onStop passedSeconds: Int64)
}

class TimerView: UIView{

    @IBOutlet weak var circleTimerView: UIView!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var activityNameLabel: UILabel!
    @IBOutlet weak var stopLabel: UILabel!
    
    weak var delegate: TimerViewDeleagte?
    var isRunning = false
    
    var timer = Timer()
    var hours: Int = 0
    var minutes: Int = 0
    var seconds: Int = 0
    var passedSeconds: Int64 = 0
    var stopTimerString: String = ""

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubViews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubViews()
    }
    
    func initSubViews() {
        let nib = UINib(nibName: "TimerView", bundle: nil)
        nib.instantiate(withOwner: self, options: nil)
        contentView.frame = bounds
        addSubview(contentView)
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.darkGray.cgColor
        
        //stopLabel.isHidden = true
        
        circleTimerView.layer.cornerRadius = 0.5 * circleTimerView.bounds.size.width
        circleTimerView.layer.borderWidth = 3
        circleTimerView.layer.borderColor = UIColor(red: 255/255, green: 115/255, blue: 110/255, alpha: 1.0).cgColor
        circleTimerView.layer.shadowOpacity = 1
        circleTimerView.layer.shadowOffset = CGSize.zero
        circleTimerView.layer.shadowRadius = 2
        addTapGesture()
    }
    
    func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapGesture(sender:)))
        contentView.addGestureRecognizer(tapGesture)
    }
    
    func onTapGesture(sender: UITapGestureRecognizer) {
        if isRunning {
            passedSeconds = onStopTimer()
            isRunning = false
            delegate?.timerView(onStop: passedSeconds)
        }
    }
    
    
    func onStartTimer() {
        isRunning = true
        passedSeconds = 0
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(TimerView.updateTimer), userInfo: nil, repeats: true)
    }
    
    func onStopTimer() -> Int64{
        passedSeconds = Int64(hours*60*60 + minutes*60 + seconds)
        print("passed seconds", passedSeconds)
        timer.invalidate()
        resetTimer()
        return passedSeconds
    }
    
    func updateTimer() {
        seconds += 1
        if seconds == 60 {
            minutes += 1
            seconds = 0
        }
        if minutes == 60 {
            hours += 1
            minutes = 0
        }
        
        if hours == 24 {
            hours = 0
        }
        
        let secondsString = seconds > 9 ? "\(seconds)" : "0\(seconds)"
        let minutuesString = minutes > 9 ? "\(minutes)" : "0\(minutes)"
        let hoursString = hours > 9 ? "\(hours)" : "0\(hours)"
        
        stopTimerString = "\(hoursString):\(minutuesString):\(secondsString)"
        timerLabel.text = stopTimerString
    }
    
    func resetTimer() {
        seconds = 0
        minutes = 0
        hours = 0
        timerLabel.text = "00:00:00"
    }
}
