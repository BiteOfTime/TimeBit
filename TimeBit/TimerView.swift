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
    @IBOutlet weak var clockImageView: UIImageView!
    
    weak var delegate: TimerViewDeleagte?
    var isRunning = false
    
    var timer: Timer!
    
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
        contentView.layer.shadowColor = UIColor(red: 2/255, green: 11/255, blue: 23/255, alpha: 1.0).cgColor
        contentView.layer.shadowOpacity = 1.0
        contentView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        contentView.layer.shadowRadius = 20
        //stopLabel.isHidden = true
        
        circleTimerView.layer.cornerRadius = 0.5 * circleTimerView.bounds.size.width
        circleTimerView.layer.borderWidth = 3
        circleTimerView.layer.borderColor = UIColor(red: 242/255, green: 108/255, blue: 79/255, alpha: 1.0).cgColor
        circleTimerView.layer.shadowOpacity = 1.0
        circleTimerView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        circleTimerView.layer.shadowRadius = 10
        circleTimerView.layer.shadowColor = UIColor(red: 2/255, green: 11/255, blue: 23/255, alpha: 1.0).cgColor
        
        //var gradientLayerView: UIView = UIView(frame: CGRectMake(0, 0, view.bounds.width, 50))
//        let gradient: CAGradientLayer = CAGradientLayer()
//        gradient.frame = contentView.bounds
//        gradient.colors = [UIColor(red: 9/255, green: 37/255, blue: 62/255, alpha: 1.0).cgColor, UIColor.clear.cgColor]
//        gradient.startPoint = CGPoint(x: 1, y: 0)
//        gradient.endPoint = CGPoint(x: 0, y: 0)
//        contentView.layer.insertSublayer(gradient, at: 0)
//        superview?.layer.insertSublayer(contentView.layer, at: 0)
        
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
    
    func zoomInTimerView() {
        if circleTimerView.transform == CGAffineTransform.identity {
            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                self.circleTimerView.transform = self.circleTimerView.transform.scaledBy(x: 1.1, y: 1.1)
            })
        }
    }
    
    func zoomOutTimerView() {
        if circleTimerView.transform != CGAffineTransform.identity {
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                self.circleTimerView.transform = CGAffineTransform.identity
            })
        }
    }
    
    func startTimeBlinkAnimation(start: Bool) {
        if start {
            timerLabel.alpha = 1
            UIView.animate(withDuration: 0.5, delay: 0.2, options:[.repeat, .autoreverse], animations: { _ in
                self.timerLabel.alpha = 0
            }, completion: nil)
        }
        else {
            timerLabel.alpha = 1
            timerLabel.layer.removeAllAnimations()
        }
    }
    
    func onStartTimer() {
        startTimeBlinkAnimation(start: true)
        zoomInTimerView()
        isRunning = true
        passedSeconds = 0
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
    }
    
    func onStopTimer() -> Int64{
        passedSeconds = Int64(hours*60*60 + minutes*60 + seconds)
        print("passed seconds", passedSeconds)
        timer.invalidate()
        resetTimer()
        return passedSeconds
    }
    
    func updateBackgroundTimer (elapsedTime: Int64) {
        UIView.animate(withDuration: 0.5) {
            self.timerLabel.alpha = 0
        }
        let elapsedSeconds = elapsedTime % 60
        let elapsedMinutes = (elapsedTime / 60) % 60
        let elapsedHours = elapsedTime / 3600

        seconds += Int(elapsedSeconds)
        minutes += Int(elapsedMinutes)
        hours += Int(elapsedHours)
        if seconds >= 60 {
            minutes += 1
            seconds -=  60
        }
        if minutes >= 60 {
            hours += 1
            minutes -= 60
        }

        let secondsString = seconds > 9 ? "\(seconds)" : "0\(seconds)"
        let minutuesString = minutes > 9 ? "\(minutes)" : "0\(minutes)"
        let hoursString = hours > 9 ? "\(hours)" : "0\(hours)"
        
        stopTimerString = "\(hoursString):\(minutuesString):\(secondsString)"
        timerLabel.text = stopTimerString
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
    }
    
    func updateTimer() {
        startTimeBlinkAnimation(start: true)
        seconds += 1
        if seconds == 60 {
            minutes += 1
            seconds = 0
        }
        if minutes == 60 {
            hours += 1
            minutes = 0
        }
        
        let secondsString = seconds > 9 ? "\(seconds)" : "0\(seconds)"
        let minutuesString = minutes > 9 ? "\(minutes)" : "0\(minutes)"
        let hoursString = hours > 9 ? "\(hours)" : "0\(hours)"
        
        stopTimerString = "\(hoursString):\(minutuesString):\(secondsString)"
        timerLabel.text = stopTimerString
    }
    
    func resetTimer() {
        zoomOutTimerView()
        startTimeBlinkAnimation(start: false)
        seconds = 0
        minutes = 0
        hours = 0
        timerLabel.text = "00:00:00"
    }
}

