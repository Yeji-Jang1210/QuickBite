//
//  MainTBC.swift
//  QuickBite
//
//  Created by 장예지 on 8/15/24.
//

import UIKit
import RxSwift

class MainTBC: UITabBarController {
    
    private enum Tab: Int, CaseIterable {
        case main
        case recipes
        case profile
        
        var title: String {
            return ""
        }
        
        var icon: UIImage? {
            switch self {
            case .main:
                return ImageAssets.main
            case .recipes:
                return ImageAssets.recipes
            case .profile:
                return ImageAssets.profile
            }
        }
        
        var vc: UIViewController {
            switch self {
            case .main:
                return UINavigationController(rootViewController: MainVC( viewModel: MainVM()))
            case .recipes:
                return UINavigationController(rootViewController: RecipesVC())
            case .profile:
                return UINavigationController(rootViewController: ProfileVC(viewModel: ProfileVM(type: .isUser)))
            }
        }
    }
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        tabBar.tintColor = Color.primaryColor
        tabBar.unselectedItemTintColor = UIColor.systemGray6
        
        let viewControllers = Tab.allCases.map { tab -> UIViewController in
            let vc = tab.vc
            vc.tabBarItem = UITabBarItem(title: "", image: tab.icon, tag: tab.rawValue)
            
            return vc
        }
        
        self.viewControllers = viewControllers
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func showToastMsg(msg: String){
        view.hideAllToasts()
        DispatchQueue.main.async {
            self.view.makeToast(msg)
        }
    }
}
