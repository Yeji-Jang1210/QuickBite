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

final class MainVC: BaseVC {
    
    private var titleLabel = {
        let object = UILabel()
        object.text = "오늘의 레시피"
        object.font = Font.semiBold(.large)
        object.textColor = Color.primaryColor
        return object
    }()
    
    private var descriptionLabel = {
        let object = UILabel()
        object.text = "따끈따끈한 레시피들을 둘러보세요 🤤"
        object.font = Font.regular(.small)
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
    
    private let collectionViewDatasource = RxCollectionViewSectionedReloadDataSource<PostSectionModel>{
        dataSource, collectionView, indexPath, item in
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MainRecipeCollectionViewCell.identifier, for: indexPath) as! MainRecipeCollectionViewCell
        cell.setData(item)
        
        return cell
    }
    
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
    
    private var viewModel: MainVM!
    private let callPostAPI = PublishRelay<Void>()
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func configureHierarchy() {
        super.configureHierarchy()
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(collectionView)
        view.addSubview(addPostButton)
    }
    
    override func configureLayout() {
        super.configureLayout()
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.centerX.equalTo(view.safeAreaLayoutGuide)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.centerX.equalTo(view.safeAreaLayoutGuide)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(20)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(UIScreen.main.bounds.width * 0.75)
        }
        
        addPostButton.snp.makeConstraints { make in
            make.size.equalTo(48)
            make.trailing.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }
    
    override func bind() {
        super.bind()
        
        let input = MainVM.Input(callPostAPI: callPostAPI,
                                 addPostButtonTap: addPostButton.rx.tap)
        let output = viewModel.transform(input: input)
        
        output.addPostButtonTap
            .bind(with: self){ owner, _ in
                owner.navigationController?.pushViewController(AddPostVC(title: "레시피 등록", isChild: true), animated: true)
            }
            .disposed(by: disposeBag)
        
        output.items
            .drive(collectionView.rx.items(dataSource: collectionViewDatasource))
            .disposed(by: disposeBag)
    }
}
