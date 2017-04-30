//
//  TimerView.swift
//  TimeBit
//
//  Created by Anisha Jain on 4/28/17.
//  Copyright © 2017 BiteOfTime. All rights reserved.
//

import UIKit

@objc protocol TimerViewDelegate {
    func timerView(onStartTimer timerView: TimerView)
    func timerView(onStopTimer timerView: TimerView, timeElapsed: UInt64)
}

class TimerView: UIView{

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var timerLabel: UILabel!
    //@IBOutlet weak var startStopButton: UIButton!
    
    weak var delegate: TimerViewDelegate?
    
    var timer = Timer()
    var hours: Int = 0
    var minutes: Int = 0
    var seconds: Int = 0
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
        
        contentView.backgroundColor = UIColor(red: 9/255, green: 37/255, blue: 62/255, alpha: 1.0)
//        startStopButton.setImage(#imageLiteral(resourceName: "Play"), for: UIControlState.normal)
//        startStopButton.setImage(#imageLiteral(resourceName: "Stop"), for: UIControlState.selected)
    }
    
    func onStartTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(TimerView.updateTimer), userInfo: nil, repeats: true)
        //print("Timer started")
        //delegate?.timerView(onStartTimer: self)
    }
    
    func onStopTimer() {
        timer.invalidate()
        resetTimer()
        //delegate?.timerView(onStopTimer: self, timeElapsed: 100)
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
    
    func getTimeElapsedInSeconds() {
        
    }
}
