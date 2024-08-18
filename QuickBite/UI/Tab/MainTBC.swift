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
                return UINavigationController(rootViewController: MainVC())
            case .recipes:
                return UINavigationController(rootViewController: RecipesVC())
            case .profile:
                return UINavigationController(rootViewController: ProfileVC())
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
        isTokenValid()
    }
    
    //toastMessage view가 바뀌어도 나타나도록 수정 필요
    
    func isTokenValid() {
        let token = Userparams.TokenRequest(refreshToken: UserDefaultsManager.shared.refreshToken, token: UserDefaultsManager.shared.token)
        UserAPI.shared.networking(service: .refreshToken(param: token), type: Userparams.TokenResponse.self)
            .debug("토큰 갱신")
            .subscribe(with: self) { owner, networkResult in
                switch networkResult {
                case .success(let result):
                    UserDefaultsManager.shared.token = result.accessToken
                case .error(let statusCode):
                    guard let error = TokenError(rawValue: statusCode) else {
                        owner.showToastMsg(msg: "알수없는 오류")
                        owner.changeRootViewController(SignInVC())
                        return
                    }
                    
                    DispatchQueue.main.async {
                        owner.showToastMsg(msg: error.message)
                        owner.changeRootViewController(SignInVC())
                    }
                    
                case .decodedError:
                    owner.showToastMsg(msg: "알수없는 오류")
                }
            }
            .disposed(by: disposeBag)
    }
    
    func showToastMsg(msg: String){
        view.hideAllToasts()
        DispatchQueue.main.async {
            self.view.makeToast(msg)
        }
    }
}
