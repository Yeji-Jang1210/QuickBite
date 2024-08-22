//
//  ProfileSettingVC.swift
//  QuickBite
//
//  Created by 장예지 on 8/21/24.
//

import UIKit
import SnapKit
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
    
    var viewModel: ProfileSettingVM!
    
    private let profileImageView = ProfileImageView(frame: .zero)
    
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
        cell.detailTextLabel?.text = item.value
        
        switch item.type {
        case .logout, .withdraw:
            break
        default:
            cell.accessoryType = .disclosureIndicator
        }
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
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(profileLabel.snp.bottom).offset(40)
            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    override func bind() {
        super.bind()
        
        let input = ProfileSettingVM.Input(itemSelected: tableView.rx.modelSelected(SettingInfo.self))
        let output = viewModel.transform(input: input)
        
        output.infoItems
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        output.selectedItem
            .bind(with: self) { owner, info in
                let vc = ProfileDetailSettingVC(title: info.type.title, isChild: true, info: info)

                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
        
    }
}

