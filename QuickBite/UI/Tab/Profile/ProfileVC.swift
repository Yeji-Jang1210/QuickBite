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
    
    private lazy var tabBarCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let object = UICollectionView(frame: .zero, collectionViewLayout: layout)
        object.showsHorizontalScrollIndicator = false
        object.register(TabBarCollectionViewCell.self, forCellWithReuseIdentifier: TabBarCollectionViewCell.identifier)
        return object
    }()
    
    private let pageCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let object = UICollectionView(frame: .zero, collectionViewLayout: layout)
        object.showsHorizontalScrollIndicator = false
        object.isPagingEnabled = true
        object.register(TabPageCollectionViewCell.self, forCellWithReuseIdentifier: TabPageCollectionViewCell.identifier)
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let firstIndexPath = IndexPath(item: 0, section: 0)
        tabBarCollectionView.selectItem(at: firstIndexPath, animated: true, scrollPosition: [])
        collectionView(tabBarCollectionView, didSelectItemAt: firstIndexPath)
        
        pageCollectionView.reloadData()
    }
    
    override func configureHierarchy() {
        super.configureHierarchy()
        
        [profileImageView, nicknameLabel, detailInfoStackView, tabBarCollectionView, pageCollectionView].map { view.addSubview($0) }
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
        
        tabBarCollectionView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.top.equalTo(detailInfoStackView.snp.bottom).offset(20)
            make.height.equalTo(44)
        }
        
        pageCollectionView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.top.equalTo(tabBarCollectionView.snp.bottom)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    override func configureUI() {
        super.configureUI()
        configureNaivgationBarItem()
        setTabbar()
    }
    
    func setTabbar() {
        pageCollectionView.delegate = self
        pageCollectionView.dataSource = self
        tabBarCollectionView.delegate = self
        tabBarCollectionView.dataSource = self
    }
    
    func configureNaivgationBarItem(){
        navigationItem.rightBarButtonItem = settingBarButtonItem
        navigationItem.rightBarButtonItem?.tintColor = Color.primaryColor
    }
    
    override func bind() {
        super.bind()
        
        let input = ProfileVM.Input(settingBarButtonTap: settingBarButtonItem.rx.tap)
        
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
        
        output.presentProfileSetting
            .bind(with: self) { owner, user in
                let vc = ProfileSettingVC(title: "프로필 수정", isChild: true, viewModel: ProfileSettingVM(user))
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
    }
}

extension ProfileVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == pageCollectionView {
            let collectionViewFrame = collectionView.frame
            return CGSize(width: collectionViewFrame.width, height: collectionViewFrame.height)
        } else {
            return CGSize(width: UIScreen.main.bounds.width / 2, height: 44)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == tabBarCollectionView {
            pageCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        } else {
            tabBarCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
        
        pageCollectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == tabBarCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TabBarCollectionViewCell.identifier, for: indexPath) as? TabBarCollectionViewCell else { return UICollectionViewCell() }
            cell.iconImageView.image = PostType.allCases[indexPath.row].icon
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TabPageCollectionViewCell.identifier, for: indexPath) as? TabPageCollectionViewCell else { return UICollectionViewCell() }
            cell.backView.backgroundColor = [.systemOrange, .systemPurple, .systemCyan, .systemMint, .systemBrown, .systemYellow].randomElement()
            cell.setTitle(title: "\(indexPath)")
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let indexPath = IndexPath(row: Int(targetContentOffset.pointee.x / UIScreen.main.bounds.width), section: 0)
        tabBarCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
    }
}
