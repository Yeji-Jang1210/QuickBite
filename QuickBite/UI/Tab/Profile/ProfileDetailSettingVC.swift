//
//  ProfileDetailSettingVC.swift
//  QuickBite
//
//  Created by 장예지 on 8/22/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class ProfileDetailSettingVC: BaseVC {
    
    private var viewModel: ProfileDetailSettingVM!
    
    init(title: String = "", isChild: Bool = false, viewModel: ProfileDetailSettingVM) {
        super.init(title: title, isChild: true)
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
