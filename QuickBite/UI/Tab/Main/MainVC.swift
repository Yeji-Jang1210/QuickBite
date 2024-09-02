//
//  MainVC.swift
//  QuickBite
//
//  Created by 장예지 on 8/15/24.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Toast
import iamport_ios
import WebKit

final class MainVC: BaseVC {
    
    private lazy var scrollView = {
        let object = UIScrollView()
        object.showsHorizontalScrollIndicator = false
        object.addSubview(contentsView)
        return object
    }()
    
    private let contentsView = UIView()
    
    private var titleLabel = {
        let object = UILabel()
        object.text = Localized.todayRecipes.title
        object.font = Font.semiBold(.large)
        object.textColor = Color.primaryColor
        return object
    }()
    
    private var descriptionLabel = {
        let object = UILabel()
        object.text = Localized.todayRecipes.description
        object.font = Font.regular(.small)
        return object
    }()
    
    private var paymentTitleLabel = {
        let object = UILabel()
        object.font = Font.semiBold(.medium)
        object.text = Localized.main_payment.text
        object.textColor = Color.primaryColor
        return object
    }()
    
    private let collectionView = {
        let layout = CarouselLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width * 0.7, height: UIScreen.main.bounds.width * 0.8)
        
        let object = UICollectionView(frame: .zero, collectionViewLayout: layout)
        object.register(MainRecipeCollectionViewCell.self, forCellWithReuseIdentifier: MainRecipeCollectionViewCell.identifier)
        object.decelerationRate = .fast
        object.showsHorizontalScrollIndicator = false
        return object
    }()
    
    private lazy var mealKitCollectionView = {
        let object = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        object.register(MealKitPaymentCollectionViewCell.self, forCellWithReuseIdentifier: MealKitPaymentCollectionViewCell.identifier)
        object.showsHorizontalScrollIndicator = false
        object.showsVerticalScrollIndicator = false
        return object
    }()
    
    private let addPostButton = {
        let object = UIButton()
        object.backgroundColor = Color.primaryColor
        object.tintColor = .white
        object.setImage(ImageAssets.recipes, for: .normal)
        object.layer.cornerRadius = 24
        
        object.layer.shadowColor = UIColor.gray.cgColor
        object.layer.shadowOpacity = 0.4
        object.layer.shadowOffset = CGSize(width: 2, height: 2)
        object.layer.shadowRadius = 3
        
        return object
    }()
    
    private lazy var webView = {
        let object = WKWebView()
        object.backgroundColor = UIColor.clear
        return object
    }()
    
    private var viewModel: MainVM!
    private let bookmarkButtonTap = PublishRelay<Post>()
    private let callPostAPI = PublishRelay<Void>()
    private let callMealKitPostAPI = PublishRelay<Void>()
    private let passPaymentInfo = PublishRelay<Post>()

    init(title: String = "", isChild: Bool = false, viewModel: MainVM) {
        super.init(title: title, isChild: isChild)
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        callPostAPI.accept(())
        callMealKitPostAPI.accept(())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func configureHierarchy() {
        super.configureHierarchy()
        view.addSubview(scrollView)
        view.addSubview(addPostButton)
        scrollView.addSubview(contentsView)
        
        contentsView.addSubview(titleLabel)
        contentsView.addSubview(descriptionLabel)
        contentsView.addSubview(collectionView)
        contentsView.addSubview(mealKitCollectionView)
        contentsView.addSubview(paymentTitleLabel)
    }
    
    override func configureLayout() {
        super.configureLayout()
        
        scrollView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.verticalEdges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentsView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.verticalEdges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(UIScreen.main.bounds.width * 0.75)
        }
        
        addPostButton.snp.makeConstraints { make in
            make.size.equalTo(48)
            make.trailing.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        paymentTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom)
                .offset(30)
            make.leading.equalToSuperview().offset(20)
        }
        
        mealKitCollectionView.snp.makeConstraints { make in
            make.top.equalTo(paymentTitleLabel.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-40)
            make.height.equalTo(470)
        }
    }
    
    override func bind() {
        super.bind()
        
        let input = MainVM.Input(callPostAPI: callPostAPI, 
                                 callMealKitPostAPI: callMealKitPostAPI,
                                 passPaymentInfo: passPaymentInfo,
                                 addPostButtonTap: addPostButton.rx.tap,
                                 modelSelected: collectionView.rx.modelSelected(Post.self))
        let output = viewModel.transform(input: input)
        
        let collectionViewDatasource = RxCollectionViewSectionedReloadDataSource<PostSectionModel>{
            dataSource, collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MainRecipeCollectionViewCell.identifier, for: indexPath) as! MainRecipeCollectionViewCell
            cell.setData(item)
            cell.bookmarkButton.rx.tap
                .bind(with: self) { owner, _ in
                    owner.viewModel.callBookmarkAPI(post: item, isSelected: cell.bookmarkButton.isSelected){ result in
                        owner.showToastMsg(msg: result ? Localized.isSave.text : Localized.isDelete.text)
                        owner.callPostAPI.accept(())
                        owner.callMealKitPostAPI.accept(())
                    }
                }
                .disposed(by: cell.disposeBag)
            
            return cell
        }
        
        let mealKitDatasource = RxCollectionViewSectionedReloadDataSource<PostSectionModel>{
            dataSource, collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MealKitPaymentCollectionViewCell.identifier, for: indexPath) as! MealKitPaymentCollectionViewCell
            
            cell.setData(item)
            cell.paymentButton.rx.tap
                .bind(with: self) { owner, _ in
                    owner.passPaymentInfo.accept(item)
                }
                .disposed(by: cell.disposeBag)
            return cell
        }
        
        output.addPostButtonTap
            .bind(with: self){ owner, _ in
                owner.navigationController?.pushViewController(AddPostVC(title: Localized.add_post_title.title, isChild: true), animated: true)
            }
            .disposed(by: disposeBag)
        
        output.items
            .drive(collectionView.rx.items(dataSource: collectionViewDatasource))
            .disposed(by: disposeBag)
        
        output.modelSelected
            .bind(with: self){ owner, post in
                let vc = DetailPostVC(viewModel: DetailPostVM(post: post))
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
        
        output.mealKitItems
            .drive(mealKitCollectionView.rx.items(dataSource: mealKitDatasource))
            .disposed(by: disposeBag)
        
        output.payment
            .bind(with: self) { owner, result in
                if let nav = owner.navigationController {
                    nav.navigationBar.isHidden = false
                    Iamport.shared.payment(navController: nav,
                                           userCode: APIInfo.userCode,
                                                  payment: result.0) { iamportResponse in
                        if let response = iamportResponse {
                            print(">>>>> payment imp_uid: \(response.imp_uid ?? "no value")")
                            print(">>>>> payment postid: \(result.1)")
                            dump(response)
                            owner.viewModel.validatePaymentResponse(response, result.1)
                        }
                    }
                }
            }
            .disposed(by: disposeBag)
        
        output.toastMessage
            .bind(with: self) { owner, msg in
                owner.showToastMsg(msg: msg)
            }
            .disposed(by: disposeBag)
        
    }
    
    func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.7))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        group.interItemSpacing = .fixed(8)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        section.contentInsets = .init(top: 0, leading: 8, bottom: 0, trailing: 8)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}
