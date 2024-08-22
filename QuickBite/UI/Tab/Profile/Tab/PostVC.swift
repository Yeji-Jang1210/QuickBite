//
//  PostVC.swift
//  QuickBite
//
//  Created by 장예지 on 8/22/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxDataSources

final class PostVC: BaseVC {
    
    private lazy var collectionView = {
        let object = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        object.register(PostCollectionViewCell.self, forCellWithReuseIdentifier: PostCollectionViewCell.identifier)
        return object
    }()
    
    private let dataSource = RxCollectionViewSectionedReloadDataSource<PostSectionModel> { dataSource, collectionView, indexPath, item in
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostCollectionViewCell.identifier, for: indexPath) as! PostCollectionViewCell
        //set First Post Image
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func configureHierarchy() {
        super.configureHierarchy()
        view.addSubview(collectionView)
    }
    
    override func configureLayout() {
        super.configureLayout()
        collectionView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(2)
            make.verticalEdges.equalToSuperview()
        }
    }
    
    override func bind() {
        super.bind()
        
        let data = Observable<[PostSectionModel]>.just(
            [PostSectionModel(items: Array(1...10).map{ Post(id: $0)})]
        )
        
        data
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3), heightDimension: .fractionalHeight(1))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1/3))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}
