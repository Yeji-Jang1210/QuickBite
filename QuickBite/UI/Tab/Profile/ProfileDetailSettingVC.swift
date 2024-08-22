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
    
    private let saveButton = {
        let object = UIBarButtonItem(title: "확인", style: .plain, target: nil, action: nil)
        object.setTitleTextAttributes([.font: Font.boldFont(.medium),
                                       .foregroundColor: Color.primaryColor], for: .normal)
        object.setTitleTextAttributes([.font: Font.boldFont(.medium),
                                       .foregroundColor: UIColor.systemGray4], for: .disabled)
        object.isEnabled = false
        return object
    }()
    
    private let textField = {
        let object = BaseTextField()
        object.imageIsHidden = true
        return object
    }()
    
    private var viewModel: ProfileDetailSettingVM!
    
    init(title: String = "", isChild: Bool = false, info: SettingInfo) {
        super.init(title: title, isChild: true)
        self.viewModel = ProfileDetailSettingVM(info: info.type)
        textField.textField.text = info.value
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func configureHierarchy() {
        super.configureHierarchy()
        view.addSubview(textField)
    }
    
    override func configureLayout() {
        super.configureLayout()
        textField.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }
    
    override func configureUI() {
        super.configureUI()
        
        navigationItem.rightBarButtonItem = saveButton
    }
    
    override func bind(){
        let input = ProfileDetailSettingVM.Input(text: textField.text.orEmpty)
        let output = viewModel.transform(input: input)
        
        output.isValid
            .drive(saveButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        output.isValid
            .map { $0 ? UIColor.green : UIColor.red }
            .drive(textField.validationStatusTextColor)
            .disposed(by: disposeBag)
        
        output.validMessage
            .asDriver(onErrorJustReturn: "")
            .drive(textField.validationStatusText)
            .disposed(by: disposeBag)
        
    }
}
