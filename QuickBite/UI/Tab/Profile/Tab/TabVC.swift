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
import SwiftUI

final class TabVC: TabmanViewController {
    enum PostType: CaseIterable {
        case userPost
        case bookMark
        
        var icon: UIImage? {
            switch self {
            case .userPost:
                return UIImage(systemName: "pencil.line")
            case .bookMark:
                return UIImage(systemName: "bookmark.fill")
            }
        }
    }
    
    private var viewControllers: [UIViewController] = []
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllers = [PostVC(), PostVC()]
        self.dataSource = self
        
        addBar(bar, dataSource: self, at: .top)
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
        item.image = PostType.allCases[index].icon
        return item
    }
}
