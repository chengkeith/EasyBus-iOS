//
//  CircleProgressView.swift
//  EasyBus
//
//  Created by KL on 22/10/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import UIKit

fileprivate extension UIColor {
    static let backgroundColor = UIColor.white
    static let outlineStrokeColor = EasyBusColor.appColor
    static let trackStrokeColor = UIColor.rgb(r: 193, g: 232, b: 251)
    static let pulsatingFillColor = UIColor.rgb(r: 242, g: 202, b: 253)
}

fileprivate extension CAShapeLayer {
    
    func commonConfig() {
        let circularPath = UIBezierPath(arcCenter: .zero, radius: radius, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        
        self.path = circularPath.cgPath
        self.lineWidth = 10
        self.lineCap = kCALineCapRound
    }
    
    func startPulsing() {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.toValue = pulsingToValue
        animation.duration = 0.8
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation.autoreverses = true
        animation.repeatCount = Float.infinity
        
        self.add(animation, forKey: "pulsing")
    }
}

/// Autolayout height = radius * pulsingToValue
fileprivate let radius: CGFloat = 80
fileprivate let pulsingToValue: CGFloat = 1.3

class CircleProgressView: UIView {
    
    let progressShapeLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.outlineStrokeColor.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeEnd = 0
        layer.transform = CATransform3DMakeRotation(-CGFloat.pi / 2, 0, 0, 1)
        layer.commonConfig()
        return layer
    }()
    let trackLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.trackStrokeColor.cgColor
        layer.fillColor = UIColor.backgroundColor.cgColor
        layer.commonConfig()
        return layer
    }()
    let pulsatingLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.clear.cgColor
        layer.fillColor = UIColor.pulsatingFillColor.cgColor
        layer.commonConfig()
        return layer
    }()
    let percentageLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = EasyBusColor.appColor
        label.font = EasyBusFont.font(type: .demiBold, 24)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .backgroundColor
        layer.addSublayer(pulsatingLayer)
        layer.addSublayer(trackLayer)
        layer.addSublayer(progressShapeLayer)
        add(percentageLabel)
        percentageLabel.al_fillSuperview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let center = self.convert(self.center, from: self.superview ?? self)
        pulsatingLayer.position = center
        trackLayer.position = center
        progressShapeLayer.position = center
    }
    
    func reloadContent() {
        if AppManager.shared.dataUpdateRequired {
            percentageLabel.text = "更新"
        }else {
            percentageLabel.text = "最新"
            pulsatingLayer.startPulsing()
        }
    }
    
    func startPulsing() {
        OperationQueue.main.addOperation {
            self.pulsatingLayer.startPulsing()
        }
    }
    
    func updateProgress(precentage: CGFloat) {
        OperationQueue.main.addOperation {
            print("updateProgress:", precentage)
            self.percentageLabel.text = "\(Int(precentage * 100))%"
            self.progressShapeLayer.strokeEnd = precentage
        }
    }
}
