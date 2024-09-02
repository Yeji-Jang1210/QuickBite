//
//  LottieIndicator.swift
//  QuickBite
//
//  Created by 장예지 on 9/2/24.
//

import UIKit
import Lottie
import SnapKit

class LottieIndicator {
    
    static let shared = LottieIndicator()
    private let animationView = LottieAnimationView(name:"loading")
    
    private lazy var container = {
        let object = UIView()
        object.addSubview(animationView)
        return object
    }()
    
    public func show() {
        
        if let keyWindow = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .compactMap({$0 as? UIWindowScene})
            .first?
            .windows
            .filter({$0.isKeyWindow})
            .first {
            
            addSubviews(keyWindow)
            
            container.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            
            animationView.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.width.equalToSuperview().multipliedBy(0.5)
                make.height.equalTo(animationView.snp.width)
            }
            
            animationView.play()
        }
    }
    
    public func dismiss() {
        animationView.pause()
        animationView.stop()
        container.removeFromSuperview()
    }
    
    private func addSubviews(_ keyWindow: UIWindow) {
        keyWindow.addSubview(container)
        container.backgroundColor = .white.withAlphaComponent(0.4)
        
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
    }
}
