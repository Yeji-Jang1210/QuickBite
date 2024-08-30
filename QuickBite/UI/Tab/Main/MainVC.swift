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
    private let bookmarkButtonTap = PublishRelay<Post>()
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
                        owner.view.makeToast(result ? "저장되었습니다." : "삭제되었습니다.")
                        owner.callPostAPI.accept(())
                    }
                }
                .disposed(by: cell.disposeBag)
            
            return cell
        }
        
        output.addPostButtonTap
            .bind(with: self){ owner, _ in
                owner.navigationController?.pushViewController(AddPostVC(title: "레시피 등록", isChild: true), animated: true)
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
        
    }
}
