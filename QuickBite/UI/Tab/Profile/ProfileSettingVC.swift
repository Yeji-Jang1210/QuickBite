//
//  ProfileSettingVC.swift
//  QuickBite
//
//  Created by 장예지 on 8/21/24.
//

import UIKit
import SnapKit
import Kingfisher
import PhotosUI

import RxSwift
import RxCocoa
import RxDataSources

enum ProfileInfo: String, CaseIterable {
    case email
    case nick
    case birthday
    case phoneNum
    case logout
    case withdraw
    
    var title: String {
        switch self {
        case .email:
            return "이메일"
        case .nick:
            return "닉네임"
        case .birthday:
            return "생년월일"
        case .phoneNum:
            return "전화번호"
        case .logout:
            return "로그아웃하기"
        case .withdraw:
            return "회원탈퇴"
        }
    }
    
    var message: String {
        switch self {
        case .logout:
            return "로그아웃 하시겠습니까?"
        case .withdraw:
            return "회원탈퇴를 진행하시겠습니까?\n 기존의 데이터들까지 초기화됩니다."
        default:
            return ""
        }
    }
    
    var placeHolder: String {
        switch self {
        case .email:
            return Localized.email_textField_placeholder.text
        case .nick:
            return Localized.nickname_textField_placeholder.text
        case .birthday:
            return Localized.signup_birtday_placeholder.text
        case .phoneNum:
            return Localized.signup_phoneNumber_placeholder.text
        default:
            return ""
        }
    }
    
    var textColor: UIColor {
        switch self {
        case .withdraw:
            return Color.primaryColor
        default:
            return UIColor.black
        }
    }
}

final class ProfileSettingVC: BaseVC {
    
    private var profileImage = PublishRelay<Data>()
    private var profileImageName = PublishRelay<String>()
    var viewModel: ProfileSettingVM!
    
    private let profileImageView = ProfileImageView(frame: .zero)
    
    private let profileImageEditButton = UIButton()
    
    private let profileLabel = {
        let object = UILabel()
        object.text = "프로필 사진 수정"
        object.font = Font.semiBold(.smallLarge)
        object.textAlignment = .center
        object.textColor = Color.primaryColor
        return object
    }()
    
    private let tableView = {
        let object = UITableView()
        object.register(ProfileSettingTableViewCell.self, forCellReuseIdentifier: ProfileSettingTableViewCell.identifier)
        return object
    }()
    
    private let dataSource = RxTableViewSectionedReloadDataSource<ProfileSettingSectionModel> { dataSource, tableView, indexPath, item in
        let cell = tableView.dequeueReusableCell(withIdentifier: ProfileSettingTableViewCell.identifier, for: indexPath)
        
        cell.textLabel?.text = item.type.title
        cell.textLabel?.textColor = item.type.textColor
        
        switch item.type {
        case .logout, .withdraw:
            return cell
        case .email:
            cell.detailTextLabel?.text = item.value
            return cell
        case .phoneNum:
            cell.detailTextLabel?.text = ValidationPhoneNumber.format(phoneNumber: item.value)
        case .birthday:
            cell.detailTextLabel?.text = ValidationBirthday.format(item.value)
        default:
            cell.detailTextLabel?.text = item.value
        }
        cell.accessoryType = .disclosureIndicator
        return cell
    } titleForHeaderInSection: { dataSource, index in
        return dataSource[index].header
    }
    
    init(title: String = "", isChild: Bool = false, viewModel: ProfileSettingVM) {
        super.init(title: title, isChild: isChild)
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func configureHierarchy() {
        super.configureHierarchy()
        
        view.addSubview(profileImageView)
        view.addSubview(profileLabel)
        view.addSubview(profileImageEditButton)
        view.addSubview(tableView)
        
    }
    
    override func configureLayout() {
        super.configureLayout()
        
        profileImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            make.size.equalTo(120)
            make.centerX.equalTo(view.safeAreaLayoutGuide)
        }
        
        profileLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(12)
            make.horizontalEdges.equalTo(profileImageView.snp.horizontalEdges)
        }
        
        profileImageEditButton.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(profileImageView)
            make.top.equalTo(profileImageView)
            make.bottom.equalTo(profileLabel)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(profileLabel.snp.bottom).offset(40)
            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    override func bind() {
        super.bind()
        let alertOkButtonTap = PublishRelay<ProfileInfo>()
        
        let input = ProfileSettingVM.Input(profileImageEditButtonTap: profileImageEditButton.rx.tap,
                                           itemSelected: tableView.rx.modelSelected(SettingInfo.self),
                                           alertOkButtonTap: alertOkButtonTap,
                                           profileImage: profileImage, 
                                           profileImageName: profileImageName)
        let output = viewModel.transform(input: input)
        
        output.infoItems
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        output.imagePath
            .drive(with: self) { owner, path in
                guard let path, let url = URL(string: "\(APIInfo.baseURL)/v1/\(path)") else {
                    owner.profileImageView.image = ImageAssets.defaultProfile
                    return
                }
                KingfisherManager.shared.defaultOptions = [.requestModifier(TokenPlugin(token: UserDefaultsManager.shared.token))]
                owner.profileImageView.kf.setImage(with: url)
            }
            .disposed(by: disposeBag)
        
        output.selectedItem
            .bind(with: self, onNext: { owner, userInfo in
                let vc = ProfileDetailSettingVC(title: userInfo.0.title, isChild: true, info: userInfo)
                owner.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
        
        output.profileImageEditButtonTap
            .bind(with: self) { owner, _ in
                var configuration = PHPickerConfiguration()
                configuration.selectionLimit = 1
                configuration.filter = .images
                
                let picker = PHPickerViewController(configuration: configuration)
                picker.delegate = owner
                owner.present(picker, animated: true)
            }
            .disposed(by: disposeBag)
        
        output.showAlert
            .flatMap { [weak self] type -> Single<(ProfileInfo, AlertType)> in
                return self?.showAlert(title: type.title, message: type.message)
                    .map { alertType in (type, alertType) } ?? .just((type, .cancel))
            }
            .bind{ type, result in
                switch result {
                case .ok:
                    alertOkButtonTap.accept(type)
                case .cancel:
                    break
                }
            }
            .disposed(by: disposeBag)
        
        output.toastMessage
            .asDriver(onErrorJustReturn: "")
            .drive(with: self){ owner, msg in
                owner.showToastMsg(msg: msg)
            }
            .disposed(by: disposeBag)
        
        output.loginViewWillPresent
            .asDriver(onErrorJustReturn: ())
            .drive(with: self){ owner, _ in
                owner.changeRootViewController(UINavigationController(rootViewController: SignInVC()))
            }
            .disposed(by: disposeBag)
        
        output.rootViewWillPresent
            .asDriver(onErrorJustReturn: ())
            .drive(with: self){ owner, _ in
                owner.navigationController?.popToRootViewController(animated: true)
            }
            .disposed(by: disposeBag)
    }
}

extension ProfileSettingVC: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        picker.dismiss(animated: true)
        
        guard let result = results.first?.itemProvider else { return }
        
        result.loadObject(ofClass: UIImage.self) { [weak self] (object, error) in
            if let image = object as? UIImage {
                DispatchQueue.main.async {
                    if let data = image.pngData() {
                        self?.profileImage.accept(data)
                    }
                }
            }
        }
        
        result.loadFileRepresentation(forTypeIdentifier: "public.item") { [weak self] url, error in
            if error != nil {
                    print("error \(error!)");
                 } else {
                     if let url = url {
                         self?.profileImageName.accept(url.lastPathComponent)
                     }
                 }
        }
    }
}
