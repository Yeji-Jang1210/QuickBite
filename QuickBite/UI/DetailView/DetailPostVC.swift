//
//  DetailPostVC.swift
//  QuickBite
//
//  Created by 장예지 on 8/28/24.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher
import Toast

final class DetailPostVC: BaseVC {
    
    let backgroundImageView = {
        let object = UIImageView()
        object.clipsToBounds = true
        object.contentMode = .scaleAspectFill
        return object
    }()
    
    let dismissButton = {
        let object = CircleButton(size: 24)
        object.backgroundColor = .white
        object.setImage(ImageAssets.leftArrow, for: .normal)
        object.tintColor = Color.primaryColor
        return object
    }()
    
    let bookmarkButton = {
        let object = CircleButton(size: 24)
        object.backgroundColor = .white
        object.setImage(ImageAssets.bookmark, for: .normal)
        object.setImage(ImageAssets.bookmarkFill, for: .selected)
        object.tintColor = Color.primaryColor
        return object
    }()
    
    private var viewModel: DetailPostVM!
    private var presentVC = PublishRelay<Void>()
    
    convenience init(viewModel: DetailPostVM!) {
        self.init()
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
    }
    
    override func configureHierarchy() {
        super.configureHierarchy()
        view.addSubview(backgroundImageView)
        view.addSubview(dismissButton)
        view.addSubview(bookmarkButton)
    }
    
    override func configureLayout() {
        super.configureLayout()
        
        backgroundImageView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.height.equalTo(UIScreen.main.bounds.height * 0.6)
        }
        
        dismissButton.snp.makeConstraints { make in
            make.size.equalTo(40)
            make.top.leading.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        bookmarkButton.snp.makeConstraints { make in
            make.size.equalTo(40)
            make.top.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }
    
    override func bind() {
        super.bind()
        
        let input = DetailPostVM.Input(presentVC: presentVC,
            dismissButtonTap: dismissButton.rx.tap,
                                       bookmarkButtonTap: bookmarkButton.rx.tap)
        let output = viewModel.transform(input: input)
        
        output.dismissButtonTap
            .bind(with: self){ owner, _ in
                owner.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
        
        output.backgroundImageURL
            .compactMap{ $0 }
            .drive(with: self){ owner, path in
                KingfisherManager.shared.defaultOptions = [.requestModifier(TokenPlugin(token: UserDefaultsManager.shared.token))]
                owner.backgroundImageView.kf.setImage(with: path)
            }
            .disposed(by: disposeBag)
        
        output.bookmarkButtonIsSelected
            .drive(bookmarkButton.rx.isSelected)
            .disposed(by: disposeBag)
        
        output.toastMessage
            .drive(with: self){ owner, msg in
                owner.showToastMsg(msg: msg)
            }
            .disposed(by: disposeBag)
        
        output.presentVC
            .bind(with: self){ owner, post in
                let vc = DetailPostContentVC(viewModel: DetailPostContentVM(post: post))
                owner.showBottomSheet(vc: vc)
            }
            .disposed(by: disposeBag)
    }
    
    func showBottomSheet(vc: BaseVC) {
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.largestUndimmedDetentIdentifier = .medium
            sheet.preferredCornerRadius = 24
            sheet.prefersScrollingExpandsWhenScrolledToEdge = true
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
        }
        
        self.present(vc, animated: false, completion: nil)
    }
}
