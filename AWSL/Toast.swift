//
//  Toast.swift
//  AWSL
//
//  Created by FlyKite on 2022/8/26.
//

import UIKit

class Toast {
    
    enum Position {
        case top
        case center
        case bottom
    }
    
    static func setup(with windowScene: UIWindowScene) {
        let window = UIWindow(windowScene: windowScene)
        window.isUserInteractionEnabled = false
        shared.window = window
    }
    
    static func show(_ msg: String,
                     duration: TimeInterval = 2.0,
                     position: Position = .bottom) {
        shared.show(msg, duration: duration, position: position)
    }
    
    private static let shared: Toast = Toast()
    
    private var window: UIWindow?
    
    private init() { }
    
    private func show(_ msg: String, duration: TimeInterval, position: Position) {
        guard let window = window else { return }
        let toast = ToastView(msg: msg, duration: duration, position: position)
        toast.show(in: window) {
            toast.removeFromSuperview()
            window.resignKey()
        }
    }
}

private class ToastView: UIView {
    
    let msg: String
    let duration: TimeInterval
    let position: Position
    
    typealias Position = Toast.Position
    
    private let container: UIView = UIView()
    private let label: UILabel = UILabel()
    
    init(msg: String, duration: TimeInterval, position: Position) {
        self.msg = msg
        self.duration = duration
        self.position = position
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show(in window: UIWindow, dismissBlock: @escaping () -> Void) {
        alpha = 0
        window.addSubview(self)
        snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        window.makeKeyAndVisible()
        performAppearAnimation(dismissBlock: dismissBlock)
    }
    
    private func performAppearAnimation(dismissBlock: @escaping () -> Void) {
        layoutIfNeeded()
        UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseOut) {
            self.alpha = 1
            self.container.snp.updateConstraints { make in
                switch self.position {
                case .top:
                    make.top.equalTo(self.safeAreaLayoutGuide).offset(32)
                case .center:
                    make.centerY.equalToSuperview()
                case .bottom:
                    make.bottom.equalTo(self.safeAreaLayoutGuide).offset(-32)
                }
            }
            self.layoutIfNeeded()
        } completion: { finished in
            DispatchQueue.main.asyncAfter(deadline: .now() + self.duration) {
                self.performDisappearAnimation(dismissBlock: dismissBlock)
            }
        }
    }
    
    private func performDisappearAnimation(dismissBlock: @escaping () -> Void) {
        layoutIfNeeded()
        UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseIn) {
            self.alpha = 0
            self.container.snp.updateConstraints { make in
                switch self.position {
                case .top:
                    make.top.equalTo(self.safeAreaLayoutGuide)
                case .center:
                    make.centerY.equalToSuperview()
                case .bottom:
                    make.bottom.equalTo(self.safeAreaLayoutGuide)
                }
            }
            self.layoutIfNeeded()
        } completion: { finished in
            dismissBlock()
        }
    }
    
    private func setupViews() {
        container.backgroundColor = UIColor(white: 0, alpha: 0.75)
        container.layer.cornerRadius = 22
        container.layer.cornerCurve = .continuous
        
        label.text = msg
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
        
        addSubview(container)
        container.addSubview(label)
        
        container.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.width.greaterThanOrEqualTo(72)
            make.centerX.equalToSuperview()
            switch position {
            case .top:
                make.top.equalTo(safeAreaLayoutGuide)
            case .center:
                make.centerY.equalToSuperview()
            case .bottom:
                make.bottom.equalTo(safeAreaLayoutGuide)
            }
        }
        
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.greaterThanOrEqualToSuperview().offset(22)
            make.right.lessThanOrEqualToSuperview().offset(-22)
        }
    }
}
