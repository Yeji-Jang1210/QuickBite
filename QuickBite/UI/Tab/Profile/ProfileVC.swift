//
//  ProfileVC.swift
//  QuickBite
//
//  Created by 장예지 on 8/15/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import Kingfisher

final class ProfileVC: BaseVC {
    private let profileImageView = ProfileImageView(frame: .zero)
    
    private let nicknameLabel = {
        let object = UILabel()
        object.textAlignment = .center
        object.font = Font.semiBold(.medium)
        return object
    }()
    
    private let emailImageView = {
        let object = UIImageView()
        object.contentMode = .scaleAspectFit
        object.image = ImageAssets.envelope
        object.tintColor = .darkGray
        return object
    }()
    
    private let emailLabel = {
        let object = UILabel()
        object.font = Font.regular(.small)
        object.textColor = .darkGray
        return object
    }()
    
    private lazy var detailInfoStackView = {
        let object = UIStackView()
        object.axis = .horizontal
        object.spacing = 12
        [emailStackView, UIView(), birthdayStackView].map { object.addArrangedSubview($0) }
        return object
    }()
    
    private lazy var emailStackView = {
        let object = UIStackView()
        object.axis = .horizontal
        object.spacing = 4
        [emailImageView, emailLabel].map { object.addArrangedSubview($0) }
        return object
    }()
    
    private let birthdayImageView = {
        let object = UIImageView()
        object.contentMode = .scaleAspectFit
        object.image = ImageAssets.cake
        object.tintColor = .darkGray
        return object
    }()
    
    //안보여줄것인지, 생일만 보여줄것인지, 생년월일 다 보여줄 것인지 선택 가능하게
    private lazy var birthdayLabel = {
        let object = UILabel()
        object.font = Font.regular(.small)
        object.textColor = .darkGray
        return object
    }()
    
    private lazy var birthdayStackView = {
        let object = UIStackView()
        object.axis = .horizontal
        object.spacing = 4
        [birthdayImageView, birthdayLabel].map { object.addArrangedSubview($0) }
        return object
    }()
    
    private lazy var settingBarButtonItem = {
        let object = UIBarButtonItem(image: ImageAssets.gear, style: .done, target: nil, action: nil)
        return object
    }()
    
    private var viewModel: ProfileVM!
    
    init(title: String = "", isChild: Bool = false, viewModel: ProfileVM) {
        super.init(title: title, isChild: isChild)
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func configureHierarchy() {
        super.configureHierarchy()
        
        [profileImageView, nicknameLabel, detailInfoStackView].map { view.addSubview($0) }
    }
    
    override func configureLayout() {
        super.configureLayout()
        
        profileImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.size.equalTo(120)
            make.centerX.equalTo(view.safeAreaLayoutGuide)
        }
        
        emailImageView.snp.makeConstraints { make in
            make.width.equalTo(emailImageView.snp.height)
        }
        
        nicknameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(20)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        detailInfoStackView.snp.makeConstraints { make in
            make.centerX.equalTo(view.safeAreaLayoutGuide)
            make.top.equalTo(nicknameLabel.snp.bottom).offset(12)
        }
    }
    
    override func configureUI() {
        super.configureUI()
        configureNaivgationBarItem()
    }
    
    func configureNaivgationBarItem(){
        navigationItem.rightBarButtonItem = settingBarButtonItem
        navigationItem.rightBarButtonItem?.tintColor = Color.primaryColor
    }
    
    override func bind() {
        super.bind()
        
        let input = ProfileVM.Input()
        
        let output = viewModel.transform(input: input)
        
        output.email
            .drive(emailLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.nickname
            .drive(nicknameLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.birthdayIsEmpty
            .drive(birthdayStackView.rx.isHidden)
            .disposed(by: disposeBag)
        
        output.birthday
            .drive(birthdayLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.imagePath
            .drive(with: self) { owner, path in
                guard let path, let url = URL(string: path) else {
                    owner.profileImageView.image = ImageAssets.defaultProfile
                    return
                }
                
                owner.profileImageView.kf.setImage(with: url)
            }
            .disposed(by: disposeBag)
        
        settingBarButtonItem.rx.tap
            .bind {
                print("tap")
            }
            .disposed(by: disposeBag)
    }
}
