//
//  UIViewController+Extension.swift
//  QuickBite
//
//  Created by 장예지 on 8/15/24.
//


import UIKit

extension UIViewController {
    func changeRootViewController(_ vc: UIViewController, animated: Bool = true){
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = windowScene.delegate as? SceneDelegate,
              let window = sceneDelegate.window else {
            return
        }
        
        if animated {
            UIView.transition(with: window, duration: 0.5, options: .transitionCurlDown) {
                let oldState = UIView.areAnimationsEnabled
                UIView.setAnimationsEnabled(false)
                window.rootViewController = vc
                UIView.setAnimationsEnabled(oldState)
            } completion: { _ in
                window.makeKeyAndVisible()
            }
            
        } else {
            window.rootViewController = vc
            window.makeKeyAndVisible()
        }
        
    }
}
