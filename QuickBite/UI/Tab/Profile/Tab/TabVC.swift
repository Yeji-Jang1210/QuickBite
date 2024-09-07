//
//  TabVC.swift
//  QuickBite
//
//  Created by 장예지 on 8/22/24.
//

import UIKit
import SnapKit
import Tabman
import Pageboy

enum PostType {
    case userPost(userId: String)
    case bookmark
    
    var icon: UIImage? {
        switch self {
        case .userPost:
            return ImageAssets.pencilLine
        case .bookmark:
            return ImageAssets.bookmarkFill
        }
    }
    
    static var icons: [UIImage?] {
        return [ImageAssets.pencilLine, ImageAssets.bookmarkFill]
    }
}

final class TabVC: TabmanViewController {
    
    private var viewControllers: [UIViewController]
    
    private lazy var bar = {
        let object = TMBarView<TMConstrainedHorizontalBarLayout, TMTabItemBarButton, TMLineBarIndicator>()
        
        object.backgroundView.style = .flat(color: .white)
        object.layout.transitionStyle = .snap
        object.buttons.customize { (button) in
            button.tintColor = .systemGray4
            button.selectedTintColor = Color.primaryColor
        }
        object.indicator.weight = .custom(value: 2)
        object.indicator.tintColor = Color.primaryColor
        
        return object
    }()
    
    init(type: ProfileType){
        switch type {
        case .isUser:
            viewControllers = [PostListVC(viewModel: PostListVM(type: .userPost(userId: UserDefaultsManager.shared.userId))), PostListVC(viewModel: PostListVM(type: .bookmark))]
        case .otherUser(let userId):
            viewControllers = [PostListVC(viewModel: PostListVM(type: .userPost(userId: type.userId)))]
        }
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        addBar(bar, dataSource: self, at: .top)
    }
    
    deinit {
        print("\(String(describing: type(of: self))) deinitialized")
    }
}

extension TabVC: PageboyViewControllerDataSource, TMBarDataSource {
    func numberOfViewControllers(in pageboyViewController: Pageboy.PageboyViewController) -> Int {
        return viewControllers.count
    }
    
    func viewController(for pageboyViewController: Pageboy.PageboyViewController, at index: Pageboy.PageboyViewController.PageIndex) -> UIViewController? {
        return viewControllers[index]
    }
     
    func defaultPage(for pageboyViewController: Pageboy.PageboyViewController) -> Pageboy.PageboyViewController.Page? {
        return .at(index: 0)
    }
    
    func barItem(for bar: any Tabman.TMBar, at index: Int) -> any Tabman.TMBarItemable {
        let item = TMBarItem(title: "")
        item.image = PostType.icons[index]
        return item
    }
}
