//
//  DetailPostContentVC.swift
//  QuickBite
//
//  Created by 장예지 on 8/29/24.
//

import UIKit
import SnapKit
import Kingfisher

import RxSwift
import RxCocoa
import RxDataSources

final class DetailPostContentVC: BaseVC {
    
    private lazy var scrollView = {
        let object = UIScrollView()
        object.showsVerticalScrollIndicator = false
        object.showsHorizontalScrollIndicator = false
        object.addSubview(contentsView)
        return object
    }()
    
    private let contentsView = UIView()
    
    private let titleLabel = {
        let object = UILabel()
        object.font = Font.semiBold(.mediumLarge)
        return object
    }()
    
    private let descriptionTextLabel = {
        let object = UILabel()
        object.text = "🧐 이 레시피는요,"
        object.font = Font.semiBold(.medium)
        return object
    }()
    
    private let creatorLabel = {
        let object = UILabel()
        object.text = "🧑🏻‍🍳 요리사"
        object.font = Font.semiBold(.medium)
        return object
    }()
    
    private let creatorImageView = {
        let object = ProfileImageView(frame: .zero)
        object.image = ImageAssets.defaultProfile
        return object
    }()
    
    private let creatorNicknameLabel = {
        let object = UILabel()
        object.textAlignment = .left
        object.font = Font.semiBold(.smallLarge)
        return object
    }()
    
    private let descriptionLabel = {
        let object = UILabel()
        object.numberOfLines = 2
        object.font = Font.regular(.smallLarge)
        object.textColor = .darkGray
        return object
    }()
    
    private let expandableButton = {
        let object = UIButton()
        object.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        object.setImage(UIImage(systemName: "chevron.up"), for: .selected)
        object.tintColor = .darkGray
        return object
    }()
    
    private lazy var stackView = {
        let object = UIStackView()
        object.axis = .vertical
        object.spacing = 12
        [descriptionTextLabel, descriptionLabel, expandableButton].map { object.addArrangedSubview($0)}
        return object
    }()
    
    private lazy var timeImageLabelView = {
        let object = VerticalImageLabel()
        object.image = ImageAssets.timer
        return object
    }()
    
    private lazy var servingsImageLabelView = {
        let object = VerticalImageLabel()
        object.image = ImageAssets.person
        return object
    }()
    
    private lazy var bookmarkCountImageLabelView = {
        let object = VerticalImageLabel()
        object.image = ImageAssets.bookmarkFill
        return object
    }()
    
    
    private lazy var cookInfoStackView = {
        let object = UIStackView()
        object.axis = .horizontal
        object.distribution = .fillEqually
        [timeImageLabelView, servingsImageLabelView, bookmarkCountImageLabelView].map { object.addArrangedSubview($0)}
        return object
    }()
    
    private let ingredientsLabel = {
        let object = UILabel()
        object.text = "🥗 재료"
        object.font = Font.semiBold(.medium)
        return object
    }()
    
    private lazy var ingredientStackView = {
        let object = UIStackView()
        object.axis = .vertical
        object.spacing = 8
        return object
    }()
    
    private let sourcesLabel = {
        let object = UILabel()
        object.text = "🧂 양념"
        object.font = Font.semiBold(.medium)
        return object
    }()
    
    private lazy var sourcesStackView = {
        let object = UIStackView()
        object.axis = .vertical
        object.spacing = 8
        return object
    }()
    
    private let stepTitleLabel = {
        let object = UILabel()
        object.text = "🍽️ 레시피 설명"
        object.font = Font.semiBold(.medium)
        return object
    }()
    
    private let stepCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 300, height: 400)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 12
        
        let object = UICollectionView(frame: .zero, collectionViewLayout: layout)
        object.register(StepCollectionViewCell.self, forCellWithReuseIdentifier: StepCollectionViewCell.identifier)
        object.showsHorizontalScrollIndicator = false
        object.isPagingEnabled = true
        return object
    }()
    
    private let stepDataSource = RxCollectionViewSectionedReloadDataSource<DetailSectionModel>{
        dataSource, collectionView, indexPath, item in
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StepCollectionViewCell.identifier, for: indexPath) as! StepCollectionViewCell
        
        cell.setDetailPostData(index: indexPath.row, item)
        return cell
    }
    
    private let pageControl = {
        let object = UIPageControl()
        object.pageIndicatorTintColor = .systemGray6
        object.currentPageIndicatorTintColor = Color.primaryColor
        return object
    }()
    
    private var viewModel: DetailPostContentVM!
    
    convenience init(viewModel: DetailPostContentVM!) {
        self.init()
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isModalInPresentation = true
    }
    
    override func configureHierarchy() {
        super.configureHierarchy()
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentsView)
        contentsView.addSubview(titleLabel)
        contentsView.addSubview(stackView)
        contentsView.addSubview(creatorLabel)
        contentsView.addSubview(creatorImageView)
        contentsView.addSubview(creatorNicknameLabel)
        contentsView.addSubview(cookInfoStackView)
        contentsView.addSubview(ingredientsLabel)
        contentsView.addSubview(ingredientStackView)
        contentsView.addSubview(sourcesLabel)
        contentsView.addSubview(sourcesStackView)
        contentsView.addSubview(stepTitleLabel)
        contentsView.addSubview(stepCollectionView)
        contentsView.addSubview(pageControl)
    }
    
    override func configureLayout() {
        super.configureLayout()
        
        scrollView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.centerX.verticalEdges.equalToSuperview()
        }
        
        contentsView.snp.makeConstraints { make in
            make.width.equalToSuperview().inset(40)
            make.centerX.equalToSuperview()
            make.verticalEdges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40)
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview()
        }
        
        creatorLabel.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.bottom).offset(40)
            make.leading.equalTo(stackView)
        }
        
        creatorImageView.snp.makeConstraints { make in
            make.size.equalTo(48)
            make.top.equalTo(creatorLabel.snp.bottom).offset(20)
            make.leading.equalTo(stackView.snp.leading)
        }
        
        creatorNicknameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(creatorImageView)
            make.leading.equalTo(creatorImageView.snp.trailing).offset(12)
            make.trailing.equalToSuperview().offset(-40)
        }
        
        cookInfoStackView.snp.makeConstraints { make in
            make.top.equalTo(creatorImageView.snp.bottom).offset(40)
            make.horizontalEdges.equalToSuperview()
        }
        
        ingredientsLabel.snp.makeConstraints { make in
            make.top.equalTo(cookInfoStackView.snp.bottom).offset(40)
            make.leading.equalTo(creatorImageView.snp.leading)
        }
        
        ingredientStackView.snp.makeConstraints { make in
            make.top.equalTo(ingredientsLabel.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview()
        }
        
        sourcesLabel.snp.makeConstraints { make in
            make.top.equalTo(ingredientStackView.snp.bottom).offset(40)
            make.leading.equalTo(creatorImageView.snp.leading)
        }
        
        sourcesStackView.snp.makeConstraints { make in
            make.top.equalTo(sourcesLabel.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview()
        }
        
        stepTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(sourcesStackView.snp.bottom).offset(40)
            make.leading.equalTo(creatorLabel)
        }
        
        stepCollectionView.snp.makeConstraints { make in
            make.top.equalTo(stepTitleLabel.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(400)
        }
        
        pageControl.snp.makeConstraints { make in
            make.top.equalTo(stepCollectionView.snp.bottom)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-40)
        }
    }
    
    override func bind() {
        super.bind()
        
        let input = DetailPostContentVM.Input(expandableButtonTap: expandableButton.rx.tap,
        pageContentOffset: stepCollectionView.rx.contentOffset,
        pageValueChanged: pageControl.rx.controlEvent(.valueChanged))
        let output = viewModel.transform(input: input)
        
        output.expandableButtonIsSelected
            .asDriver(onErrorJustReturn: false)
            .drive(expandableButton.rx.isSelected)
            .disposed(by: disposeBag)
        
        output.descriptionNumberOfLines
            .drive(with: self){ owner, lines in
                UIView.animate(withDuration: 0.3) {
                    owner.descriptionLabel.numberOfLines = lines
                    owner.view.layoutIfNeeded()
                }
            }
            .disposed(by: disposeBag)
        
        output.titleText.drive(titleLabel.rx.text).disposed(by: disposeBag)
        output.descriptionText.drive(descriptionLabel.rx.text).disposed(by: disposeBag)
        output.creatorNicknameText.drive(creatorNicknameLabel.rx.text).disposed(by: disposeBag)
        output.timeText.drive(timeImageLabelView.text).disposed(by: disposeBag)
        output.servingsText.drive(servingsImageLabelView.text).disposed(by: disposeBag)
        output.bookmarkText.drive(bookmarkCountImageLabelView.text).disposed(by: disposeBag)
        
        output.ingredients
            .drive(with: self) { owner, ingredients in
                for ingredient in ingredients {
                    owner.ingredientStackView.addArrangedSubview(IngredientStackView(name: ingredient.name, ratio: ingredient.ratio))
                }
            }
            .disposed(by: disposeBag)
        
        output.sources
            .drive(with: self) { owner, sources in
                for ingredient in sources {
                    owner.sourcesStackView.addArrangedSubview(IngredientStackView(name: ingredient.name, ratio: ingredient.ratio))
                }
            }
            .disposed(by: disposeBag)
        
        output.creatorProfilePath
            .drive(with: self){ owner, path in
                if let path, let url = URL(string: "\(APIInfo.baseURL)/v1/\(path)") {
                    KingfisherManager.shared.defaultOptions = [.requestModifier(TokenPlugin(token: UserDefaultsManager.shared.token))]
                    let processor = DownsamplingImageProcessor(size: owner.creatorImageView.frame.size)
                    owner.creatorImageView.kf.indicatorType = .activity
                    owner.creatorImageView.kf.setImage(with: url,
                                                       placeholder: nil,
                                                       options: [.transition(.none), .forceTransition, .processor(processor)],
                                                       completionHandler: nil)
                } else {
                    owner.creatorImageView.image = ImageAssets.defaultProfile
                }
            }
            .disposed(by: disposeBag)
        
        output.stepDataSource
            .drive(stepCollectionView.rx.items(dataSource: stepDataSource))
            .disposed(by: disposeBag)
        
        output.steps
            .map { $0.count }
            .drive(pageControl.rx.numberOfPages)
            .disposed(by: disposeBag)
        
        output.pageContentOffset
            .flatMap {
                return Observable.just(Int($0.x / 300))
            }
            .bind(with: self){ owner, page in
                owner.pageControl.currentPage = page
                owner.pageControl.setCurrentPageIndicatorImage(ImageAssets.main, forPage: page)
            }
            .disposed(by: disposeBag)
    
        output.pageValueChanged
            .withLatestFrom(Observable.just(pageControl.currentPage))
            .subscribe(onNext: { [weak self] page in
                guard let self = self else { return }
                let indexPath = IndexPath(item: page, section: 0)
                self.stepCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            })
            .disposed(by: disposeBag)
    }
}
