//
//  RecipesVC.swift
//  QuickBite
//
//  Created by 장예지 on 8/15/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxDataSources

final class RecipesVC: BaseVC {
    private lazy var collectionView = {
        let object = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        object.register(RecipesCollectionViewCell.self, forCellWithReuseIdentifier: RecipesCollectionViewCell.identifier)
        object.register(RecipesReusableHeaderView.self,
                        forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                        withReuseIdentifier: RecipesReusableHeaderView.identifier)
        return object
    }()
    
    private let datasource = RxCollectionViewSectionedReloadDataSource<PostSectionModel>(configureCell: {
        dataSource, collectionView, indexPath, item in
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecipesCollectionViewCell.identifier, for: indexPath) as! RecipesCollectionViewCell
        
        if let path = item.files.last {
            cell.setImage("\(APIInfo.baseURL)/v1/\(path)")
        }
        cell.setCount(item.likes.count)
        return cell
    }) { dataSource, collectionView, kind, indexPath in
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: RecipesReusableHeaderView.identifier, for: indexPath) as! RecipesReusableHeaderView
            return header
        default:
            fatalError()
        }
    }
    
    private let viewModel = RecipesVM()
    private let callPostAPI = PublishRelay<Void>()
    private var nextCursor: String = ""
    private var isLastPage: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        //데이터 다시 불러오기
        isLastPage = false
        viewModel.items = []
        viewModel.isFirstPage = true
        viewModel.nextCursor.accept("")
        callPostAPI.accept(())
    }
    
    override func configureHierarchy() {
        super.configureHierarchy()
        view.addSubview(collectionView)
    }
    
    override func configureLayout() {
        super.configureLayout()
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    override func bind() {
        super.bind()
        
        let input = RecipesVM.Input(callPostAPI: callPostAPI,
                                    modelSelected: collectionView.rx.modelSelected(Post.self))
        let output = viewModel.transform(input: input)
        
        output.items
            .drive(collectionView.rx.items(dataSource: datasource))
            .disposed(by: disposeBag)
        
        collectionView.rx.didScroll
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .bind(with: self) { owner, _ in
                if owner.collectionView.contentOffset.y > (owner.collectionView.contentSize.height - owner.collectionView.bounds.size.height) {
                    if owner.nextCursor != "0" && !owner.isLastPage {
                        owner.callPostAPI.accept(())
                    }
                }
            }
            .disposed(by: disposeBag)
            
        output.Cursor
            .bind(with: self, onNext: { owner, result in
                owner.nextCursor = result
            })
            .disposed(by: disposeBag)
        
        output.isLastPage
            .bind(with: self, onNext: { owner, result in
                owner.isLastPage = result
            })
            .disposed(by: disposeBag)
        
        output.modelSelected
            .bind(with: self){ owner, post in
                let vc = DetailPostVC(viewModel: DetailPostVM(post: post))
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.5))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        group.interItemSpacing = .fixed(8)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize,
                                                                 elementKind: UICollectionView.elementKindSectionHeader,
                                                                 alignment: .top)
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        section.contentInsets = .init(top: 0, leading: 8, bottom: 0, trailing: 8)
        section.boundarySupplementaryItems = [header]
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}
