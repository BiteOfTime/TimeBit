//
//  TimerView.swift
//  TimeBit
//
//  Created by Anisha Jain on 4/28/17.
//  Copyright © 2017 BiteOfTime. All rights reserved.
//

import UIKit

class TimerView: UIView{

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var timerLabel: UILabel!
    
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
    }
    
    func onStartTimer() {
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
