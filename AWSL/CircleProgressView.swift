//
//  CircleProgressView.swift
//  AWSL
//
//  Created by FlyKite on 2022/8/26.
//

import UIKit

class CircleProgressView: UIView {
    
    var progress: Float = 0 {
        didSet {
            shapeLayer.strokeEnd = CGFloat(progress)
        }
    }
    
    private let shapeLayer: CAShapeLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.lineWidth = 3
        shapeLayer.lineCap = .round
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeEnd = 0
        
        layer.addSublayer(shapeLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let path = UIBezierPath(arcCenter: CGPoint(x: bounds.width / 2, y: bounds.height / 2),
                                radius: min(bounds.width, bounds.height) / 2 - 1.5,
                                startAngle: -CGFloat.pi / 2,
                                endAngle: CGFloat.pi * 1.5,
                                clockwise: true)
        shapeLayer.path = path.cgPath
    }
}
