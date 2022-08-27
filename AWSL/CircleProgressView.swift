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
            shapeLayer.strokeEnd = max(0.08, CGFloat(progress))
        }
    }
    
    private let bgLayer: CAShapeLayer = CAShapeLayer()
    private let shapeLayer: CAShapeLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        bgLayer.fillColor = UIColor(white: 0, alpha: 0.75).cgColor
        
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.lineWidth = 4
        shapeLayer.lineCap = .round
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeEnd = 0.02
        
        layer.addSublayer(bgLayer)
        layer.addSublayer(shapeLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let size = min(bounds.width, bounds.height)
        bgLayer.path = UIBezierPath(arcCenter: center, radius: size / 2, startAngle: 0, endAngle: .pi * 2, clockwise: true).cgPath
        let path = UIBezierPath(arcCenter: center,
                                radius: size / 2 - 4,
                                startAngle: -.pi / 2,
                                endAngle: .pi * 1.5,
                                clockwise: true)
        shapeLayer.path = path.cgPath
    }
}
