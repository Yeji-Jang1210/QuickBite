//
//  AddPostVC.swift
//  QuickBite
//
//  Created by 장예지 on 8/26/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxDataSources
import Lottie

enum TimeType: CaseIterable {
    case minute
    case hour
    
    var text: String {
        switch self {
        case .minute:
            return "분"
        case .hour:
            return "시간"
        }
    }
}

final class AddPostVC: BaseVC {
    
    private let loadAnimation: LottieAnimationView = {
        let object = LottieAnimationView(name: "loading")
        object.loopMode = .loop
        return object
    }()
    
    private lazy var container: UIView = {
        let object = UIView()
        object.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        object.addSubview(loadAnimation)
        object.isHidden = true
        return object
    }()
    
    private lazy var scrollView = {
        let object = UIScrollView()
        object.showsHorizontalScrollIndicator = false
        object.addSubview(contentsView)
        return object
    }()
    
    private let contentsView = UIView()
    
    private let firstTitleLabel = {
        let object = UILabel()
        object.font = Font.regular(.medium)
        object.text = "오늘의 레시피 제목은"
        return object
    }()
    
    private var titleTextField = {
        let object = BaseTextField()
        object.imageIsHidden = true
        object.font = Font.semiBold(.mediumLarge)
        return object
    }()
    
    private let descriptionContentLabel = {
        let object = UILabel()
        object.font = Font.regular(.smallLarge)
        object.text = "이 레시피는요,"
        return object
    }()
    
    private let descriptionTextView = {
        let object = BlockTextView(minimumHeight: 180, maxCount: 100)
        return object
    }()
    
    private let lastTitleLabel = {
        let object = UILabel()
        object.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        object.font = Font.regular(.medium)
        object.text = "입니다."
        return object
    }()
    
    private let stepLabel = {
        let object = UILabel()
        object.text = "레시피를 등록해주세요!"
        object.font = Font.semiBold(.medium)
        object.textColor = Color.primaryColor
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
        return object
    }()
    
    private let stepDataSource = RxCollectionViewSectionedReloadDataSource<StepSectionModel>{
        dataSource, collectionView, indexPath, item in
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StepCollectionViewCell.identifier, for: indexPath) as! StepCollectionViewCell
            
        cell.setData(index: indexPath.row, item)
        return cell
    }
    
    private let ingredientsLabel = {
        let object = UILabel()
        object.text = "🥗 재료"
        object.font = Font.semiBold(.medium)
        object.textColor = Color.primaryColor
        return object
    }()
    
    private let ingredientStackView = {
        let object = UIStackView()
        object.axis = .vertical
        object.spacing = 8
        return object
    }()
    
    private let ingredientAddView = {
        let object = AddRecipeIngredientView()
        return object
    }()
    
    private let sourcesLabel = {
        let object = UILabel()
        object.text = "🧂 양념"
        object.font = Font.semiBold(.medium)
        object.textColor = Color.primaryColor
        return object
    }()
    
    private let sourceStackView = {
        let object = UIStackView()
        object.axis = .vertical
        object.spacing = 8
        return object
    }()
    
    private let servingsLabel = {
        let object = UILabel()
        object.text = "🍚 이 요리는 몇인분 기준인가요?"
        object.font = Font.semiBold(.medium)
        object.textColor = Color.primaryColor
        return object
    }()
    
    private let servingsStepperView = StepperView(detailText: "인분")
    
    private let timeLabel = {
        let object = UILabel()
        object.text = "⏰ 조리 시간을 알려주세요"
        object.font = Font.semiBold(.medium)
        object.textColor = Color.primaryColor
        return object
    }()
    
    private let minuteLabel = {
        let object = UILabel()
        object.text = "분"
        object.font = Font.semiBold(.medium)
        return object
    }()
    
    private lazy var timeInputView = {
        let object = UIView()
        [timeTextField, minuteLabel].map { object.addSubview($0)}
        return object
    }()
    
    private let timeTextField = {
        let object = BaseTextField()
        object.imageIsHidden = true
        return object
    }()
    
    private let sourceAddView = {
        let object = AddRecipeIngredientView()
        return object
    }()
    
    private let saveButton = {
        let object = UIBarButtonItem(title: "확인", style: .plain, target: nil, action: nil)
        object.setTitleTextAttributes([.font: Font.boldFont(.medium),
                                       .foregroundColor: Color.primaryColor], for: .normal)
        object.setTitleTextAttributes([.font: Font.boldFont(.medium),
                                       .foregroundColor: UIColor.systemGray4], for: .disabled)
        object.isEnabled = false
        return object
    }()
    
    private let pushStepVC = PublishRelay<Void>()
    private let viewModel = AddPostVM()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    override func configureHierarchy() {
        super.configureHierarchy()
        view.addSubview(scrollView)
        view.addSubview(container)
        
        scrollView.addSubview(contentsView)
        
        contentsView.addSubview(firstTitleLabel)
        contentsView.addSubview(titleTextField)
        contentsView.addSubview(lastTitleLabel)
        contentsView.addSubview(descriptionContentLabel)
        contentsView.addSubview(descriptionTextView)
        
        contentsView.addSubview(stepLabel)
        contentsView.addSubview(stepCollectionView)
        
        contentsView.addSubview(ingredientsLabel)
        contentsView.addSubview(ingredientStackView)
        contentsView.addSubview(ingredientAddView)
        
        contentsView.addSubview(sourcesLabel)
        contentsView.addSubview(sourceStackView)
        contentsView.addSubview(sourceAddView)
        
        contentsView.addSubview(servingsLabel)
        contentsView.addSubview(servingsStepperView)
        contentsView.addSubview(timeLabel)
        contentsView.addSubview(timeInputView)
    }
    
    override func configureLayout() {
        super.configureLayout()
        
        container.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        loadAnimation.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
            make.height.equalTo(loadAnimation.snp.width)
        }
        
        scrollView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.verticalEdges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentsView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(20)
            make.width.equalToSuperview().inset(20)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(100)
        }
        
        firstTitleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
        }
        
        titleTextField.snp.makeConstraints { make in
            make.top.equalTo(firstTitleLabel.snp.bottom).offset(12)
            make.leading.equalTo(firstTitleLabel)
            make.trailing.equalTo(lastTitleLabel.snp.leading).offset(-12)
        }
        
        lastTitleLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalTo(titleTextField)
        }
        
        descriptionContentLabel.snp.makeConstraints { make in
            make.top.equalTo(titleTextField.snp.bottom).offset(40)
            make.leading.equalToSuperview()
        }
        
        descriptionTextView.snp.makeConstraints { make in
            make.top.equalTo(descriptionContentLabel.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview()
        }
        
        stepLabel.snp.makeConstraints { make in
            make.top.equalTo(descriptionTextView.snp.bottom).offset(40)
            make.horizontalEdges.equalToSuperview()
        }
        
        stepCollectionView.snp.makeConstraints { make in
            make.top.equalTo(stepLabel.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(400)
        }
        
        ingredientsLabel.snp.makeConstraints { make in
            make.top.equalTo(stepCollectionView.snp.bottom).offset(40)
            make.leading.equalToSuperview()
        }
        
        ingredientStackView.snp.makeConstraints { make in
            make.top.equalTo(ingredientsLabel.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview()
        }
        
        ingredientAddView.snp.makeConstraints { make in
            make.top.equalTo(ingredientStackView.snp.bottom).offset(12)
            make.horizontalEdges.equalToSuperview()
        }
        
        sourcesLabel.snp.makeConstraints { make in
            make.top.equalTo(ingredientAddView.snp.bottom).offset(40)
            make.leading.equalToSuperview()
        }
        
        sourceStackView.snp.makeConstraints { make in
            make.top.equalTo(sourcesLabel.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview()
        }
        
        sourceAddView.snp.makeConstraints { make in
            make.top.equalTo(sourceStackView.snp.bottom).offset(12)
            make.horizontalEdges.equalToSuperview()
        }
        
        servingsLabel.snp.makeConstraints { make in
            make.top.equalTo(sourceAddView.snp.bottom).offset(40)
            make.horizontalEdges.equalToSuperview()
        }
        
        servingsStepperView.snp.makeConstraints { make in
            make.top.equalTo(servingsLabel.snp.bottom).offset(12)
            make.horizontalEdges.equalToSuperview().inset(30)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(servingsStepperView.snp.bottom).offset(40)
            make.horizontalEdges.equalToSuperview()
        }
        
        timeInputView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(timeLabel.snp.bottom).offset(12)
            make.bottom.equalToSuperview()
        }
        
        timeTextField.snp.makeConstraints { make in
            make.width.equalTo(80)
            make.leading.verticalEdges.equalToSuperview()
        }
        
        minuteLabel.snp.makeConstraints { make in
            make.leading.equalTo(timeTextField.snp.trailing).offset(12)
            make.trailing.centerY.equalToSuperview()
        }
        
    }
    
    override func configureUI() {
        super.configureUI()
        navigationItem.rightBarButtonItem = saveButton
    }
    
    override func bind() {
        super.bind()
        let deleteIngredients = PublishRelay<Int>()
        let deleteSources = PublishRelay<Int>()
        let appendStep = PublishRelay<(Step?,Int)>()
        
        let input = AddPostVM.Input(titleText: titleTextField.text.orEmpty,
                                    descriptionText: descriptionTextView.textView.rx.text.orEmpty,
                                    stepItemSelected: stepCollectionView.rx.itemSelected,
                                    stepModelSelected: stepCollectionView.rx.modelSelected(Step?.self),
                                    ingredientsTitle: ingredientAddView.titleTextField.text.orEmpty,
                                    ingredientsRatio: ingredientAddView.ratioTextField.text.orEmpty,
                                    addIngredientTap: ingredientAddView.addButton.rx.tap,
                                    deleteIngredients: deleteIngredients,
                                    sourcesTitle: sourceAddView.titleTextField.text.orEmpty,
                                    sourcesRatio: sourceAddView.ratioTextField.text.orEmpty,
                                    addSourceTap: sourceAddView.addButton.rx.tap,
                                    servingsValue: servingsStepperView.value,
                                    timeText: timeTextField.text.orEmpty,
                                    deleteSources: deleteSources,
                                    appendStep: appendStep,
                                    saveButtonTap: saveButton.rx.tap)
        
        let output = viewModel.transform(input: input)
        
        output.titleText
            .map { String($0.prefix(15)) }
            .bind(to: titleTextField.text)
            .disposed(by: disposeBag)
        
        output.stepItems
            .drive(stepCollectionView.rx.items(dataSource: stepDataSource))
            .disposed(by: disposeBag)
        
        output.ingredientItems
            .drive(with: self) { owner, ingredients in
                self.ingredientStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
                
                for (index, ingredient) in ingredients.enumerated() {
                    let view = RecipeIngredientView(ingredient)
                    
                    view.deleteButton.tag = index
                    view.deleteButton.rx.tap
                        .map{ view.deleteButton.tag }
                        .bind(with: self) { owner, tag in
                            deleteIngredients.accept(index)
                        }
                        .disposed(by: owner.disposeBag)
                    
                    owner.ingredientStackView.addArrangedSubview(view)
                }
            }
            .disposed(by: disposeBag)
        
        output.sourceItems
            .drive(with: self) { owner, sources in
                self.sourceStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
                
                for (index, sources) in sources.enumerated() {
                    let view = RecipeIngredientView(sources)
                    
                    view.deleteButton.tag = index
                    view.deleteButton.rx.tap
                        .map{ view.deleteButton.tag }
                        .bind(with: self) { owner, tag in
                            deleteSources.accept(index)
                        }
                        .disposed(by: owner.disposeBag)
                    
                    owner.sourceStackView.addArrangedSubview(view)
                }
            }
            .disposed(by: disposeBag)
        
        output.clearIngredientTextField
            .map { "" }
            .emit(to:self.ingredientAddView.titleTextField.text, self.ingredientAddView.ratioTextField.text)
            .disposed(by: disposeBag)
        
        output.clearSourceTextField
            .map { "" }
            .emit(to:self.sourceAddView.titleTextField.text, self.sourceAddView.ratioTextField.text)
            .disposed(by: disposeBag)
        
        output.timeText
            .drive(timeTextField.text)
            .disposed(by: disposeBag)
        
        output.stepItemSelected
            .drive(with: self){ owner, result in
                let (step, indexPath) = result
                guard let indexPath = indexPath else { return }
                
                let vc = AddStepVC(title: "작성하기", isChild: true)
                vc.setData(step)
                
                vc.completionHandler = { data in
                    appendStep.accept((data,indexPath.row))
                }
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
        
        output.isAllAlowed
            .drive(saveButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        output.toastMessage
            .drive(with: self){ owner, msg in
                owner.showToastMsg(msg: msg)
            }
            .disposed(by: disposeBag)
        
        output.addPostSucceess
            .asDriver(onErrorJustReturn: ())
            .drive(with: self) { owner, _ in
                owner.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
        
        output.loadAnimation
            .drive(with: self){ owner, isLoading in
                owner.container.isHidden = !isLoading
                if isLoading {
                    owner.loadAnimation.play()
                } else {
                    owner.loadAnimation.stop()
                }
            }
            .disposed(by: disposeBag)
            
    }
}
