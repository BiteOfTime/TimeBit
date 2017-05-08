//
//  PDLineChart.swift
//  TimeBit
//
//  Created by Namrata Mehta on 5/6/17.
//  Copyright © 2017 BiteOfTime. All rights reserved.
//

import UIKit
import QuartzCore

class PDLineChartDataItem {
    //optional
    var axesColor: UIColor = UIColor(red: 80.0 / 255, green: 80.0 / 255, blue: 80.0 / 255, alpha: 1.0)           
    var axesTipColor: UIColor = UIColor(red: 80.0 / 255, green: 80.0 / 255, blue: 80.0 / 255, alpha: 1.0)
    var chartLayerColor: UIColor = UIColor(red: 61.0 / 255, green: 189.0 / 255, blue: 100.0 / 255, alpha: 1.0)
    var showAxes: Bool = true
    
    var xAxesDegreeTexts: [String]?
    var yAxesDegreeTexts: [String]?
    
    //require
    var xMax: CGFloat!
    var xInterval: CGFloat!
    
    var yMax: CGFloat!
    var yInterval: CGFloat!
    
    var pointArray: [CGPoint]?
    init() {
        
    }
}

class PDLineChart: PDChart {
    var axesComponent: PDChartAxesComponent!
    var dataItem: PDLineChartDataItem!
    
    init(frame: CGRect, dataItem: PDLineChartDataItem) {
        super.init(frame: frame)
        
        self.dataItem = dataItem
        
        let axesDataItem: PDChartAxesComponentDataItem = PDChartAxesComponentDataItem()
        axesDataItem.targetView = self
        axesDataItem.featureH = self.getFeatureHeight()
        axesDataItem.featureW = self.getFeatureWidth()
        axesDataItem.xMax = dataItem.xMax
        axesDataItem.xInterval = dataItem.xInterval
        axesDataItem.yMax = dataItem.yMax
        axesDataItem.yInterval = dataItem.yInterval
        axesDataItem.xAxesDegreeTexts = dataItem.xAxesDegreeTexts
        axesDataItem.yAxesDegreeTexts = dataItem.yAxesDegreeTexts
        
        axesComponent = PDChartAxesComponent(dataItem: axesDataItem)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getFeatureWidth() -> CGFloat {
        return CGFloat(self.frame.size.width)
    }
    
    func getFeatureHeight() -> CGFloat {
        return CGFloat(self.frame.size.height)
    }
    
    override func strokeChart() {
        if !(self.dataItem.pointArray != nil) {
            return
        }
        
        let chartLayer: CAShapeLayer = CAShapeLayer()
        chartLayer.lineCap = kCALineCapRound
        chartLayer.lineJoin = kCALineJoinRound
        chartLayer.fillColor = UIColor.white.cgColor
        chartLayer.strokeColor = self.dataItem.chartLayerColor.cgColor
        chartLayer.lineWidth = 2.0
        chartLayer.strokeStart = 0.0
        chartLayer.strokeEnd = 1.0
        self.layer.addSublayer(chartLayer)
        
        UIGraphicsBeginImageContext(self.frame.size)
        
        let progressLine: UIBezierPath = UIBezierPath()
        
        let basePoint: CGPoint = axesComponent.getBasePoint()
        let xAxesWidth: CGFloat = axesComponent.getXAxesWidth()
        let yAxesHeight: CGFloat = axesComponent.getYAxesHeight()
        for i in 0..<self.dataItem.pointArray!.count {
            let point: CGPoint = self.dataItem.pointArray![i]
            let pixelPoint: CGPoint = CGPoint(x: basePoint.x + point.x / self.dataItem.xMax * xAxesWidth, y: basePoint.y - point.y / self.dataItem.yMax * yAxesHeight)
            
            if i == 0 {
                progressLine.move(to: pixelPoint)
            } else {
                progressLine.addLine(to: pixelPoint)
            }
        }
        
        progressLine.stroke()
        
        chartLayer.path = progressLine.cgPath
        
        CATransaction.begin()
        let pathAnimation: CABasicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        pathAnimation.duration = 1.0
        pathAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        pathAnimation.fromValue = 0.0
        pathAnimation.toValue = 1.0
        
        //func addAnimation(anim: CAAnimation!, forKey key: String!)
        chartLayer.add(pathAnimation, forKey: "strokeEndAnimation")
        
        
        //class func setCompletionBlock(block: (() -> Void)!)
        CATransaction.setCompletionBlock({
            () -> Void in
        })
        CATransaction.commit()
        
        UIGraphicsEndImageContext()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let context: CGContext = UIGraphicsGetCurrentContext()!
        axesComponent.strokeAxes(context)
    }
}
