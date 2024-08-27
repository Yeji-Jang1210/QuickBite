//
//  AddStepVC.swift
//  QuickBite
//
//  Created by 장예지 on 8/26/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import PhotosUI

final class AddStepVC: BaseVC {
    
    private lazy var scrollView = {
        let object = UIScrollView()
        object.showsHorizontalScrollIndicator = false
        object.addSubview(contentsView)
        return object
    }()
    
    private let contentsView = UIView()
    
    private let imageView = {
        let object = UIImageView()
        object.clipsToBounds = true
        object.layer.cornerRadius = 8
        object.backgroundColor = .systemGray6
        object.contentMode = .scaleAspectFill
        return object
    }()
    
    private let titleLabel = {
        let object = UILabel()
        object.font = Font.semiBold(.smallLarge)
        return object
    }()
    
    private let galleryLabel = {
        let object = UILabel()
        object.text = "사진을 선택해 주세요"
        object.font = Font.semiBold(.smallLarge)
        object.textColor = Color.primaryColor
        return object
    }()
    
    private let galleryButton = {
        let object = UIButton()
        object.setImage(UIImage(systemName: "plus"), for: .normal)
        object.tintColor = Color.primaryColor
        return object
    }()
    
    private let titleTextField = {
       let object = BaseTextField()
        object.imageIsHidden = true
        object.placeholder = "제목을 15자 이내로 입력해 주세요"
        return object
    }()
    
    private let descriptionLabel = {
        let object = UILabel()
        object.text = "설명을 입력해 주세요"
        object.font = Font.semiBold(.smallLarge)
        return object
    }()
    
    private let descriptionTextField = {
       let object = BaseTextField()
        object.placeholder = "설명을 25자 이내로 입력해 주세요"
        object.imageIsHidden = true
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
    
    private let viewModel = AddStepVM()
    var completionHandler: ((Step?) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func configureHierarchy() {
        super.configureHierarchy()
        view.addSubview(scrollView)
        scrollView.addSubview(contentsView)
        
        contentsView.addSubview(galleryLabel)
        contentsView.addSubview(imageView)
        contentsView.addSubview(titleLabel)
        contentsView.addSubview(galleryButton)
        contentsView.addSubview(titleTextField)
        contentsView.addSubview(descriptionTextField)
        contentsView.addSubview(descriptionLabel)
    }
    
    override func configureLayout() {
        super.configureLayout()
        
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
        
        galleryLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
        }
        
        galleryButton.snp.makeConstraints { make in
            make.trailing.top.equalToSuperview()
            make.size.equalTo(24)
        }
        
        imageView.snp.makeConstraints { make in
            make.top.equalTo(galleryLabel.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(imageView.snp.width).multipliedBy(1.3)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(40)
            make.horizontalEdges.equalToSuperview()
        }
        
        titleTextField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.horizontalEdges.equalToSuperview()
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleTextField.snp.bottom).offset(40)
            make.horizontalEdges.equalToSuperview()
        }
        
        descriptionTextField.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(12)
            make.bottom.horizontalEdges.equalToSuperview()
        }
        
    }
    
    override func configureUI() {
        super.configureUI()
        navigationItem.rightBarButtonItem = saveButton
    }
    
    override func bind() {
        super.bind()
        
        let input = AddStepVM.Input(galleryButtonTap: galleryButton.rx.tap,
                                    titleText: titleTextField.text.orEmpty,
                                    descriptionText: descriptionTextField.text.orEmpty,
                                    saveButtonTap: saveButton.rx.tap)
        
        let output = viewModel.transform(input: input)
        
        output.galleryButtonTap
            .bind(with: self) { owner, _ in
                var configuration = PHPickerConfiguration()
                configuration.selectionLimit = 1
                configuration.filter = .images
                
                let picker = PHPickerViewController(configuration: configuration)
                picker.delegate = owner
                owner.present(picker, animated: true)
            }
            .disposed(by: disposeBag)
        
        output.titleText
            .drive(titleTextField.text)
            .disposed(by: disposeBag)
        
        output.descriptionText
            .drive(descriptionTextField.text)
            .disposed(by: disposeBag)
        
        output.titleText
            .map { "제목을 15자 내외로 입력해 주세요. \($0.count)/15"}
            .asDriver(onErrorJustReturn: "")
            .drive(titleLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.descriptionText
            .map { "내용을 25자 내외로 입력해 주세요. \($0.count)/25"}
            .asDriver(onErrorJustReturn: "")
            .drive(descriptionLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.isEnableSaveButton
            .drive(saveButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        output.image
            .compactMap{$0}
            .map{ UIImage(data: $0) }
            .drive(imageView.rx.image)
            .disposed(by: disposeBag)
        
        output.outputDismissView
            .drive(with: self) { owner, result in
                owner.completionHandler?(result)
                owner.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    func setData(_ step: Step?){
        guard let step = step else { return }
        
        Observable.just(step.imageData)
            .compactMap { $0?.image }
            .bind(with: self) { owner, data in
                owner.viewModel.stepImageData.accept(data)
            }
            .disposed(by: disposeBag)
        
        Observable.just(step.title)
            .bind(to: titleTextField.text)
            .disposed(by: disposeBag)
        
        Observable.just(step.description)
            .bind(to: descriptionTextField.text)
            .disposed(by: disposeBag)
    }
}

extension AddStepVC: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        picker.dismiss(animated: true)
        
        guard let result = results.first?.itemProvider else { return }
        
        result.loadObject(ofClass: UIImage.self) { [weak self] (object, error) in
            if let image = object as? UIImage {
                DispatchQueue.main.async {
                    if let data = image.pngData() {
                        self?.viewModel.stepImageData.accept(data)
                    }
                }
            }
        }
        
        result.loadFileRepresentation(forTypeIdentifier: "public.item") { [weak self] url, error in
            if error != nil {
                    print("error \(error!)");
                 } else {
                     if let url = url {
                         self?.viewModel.stepImageName.accept(url.lastPathComponent)
                     }
                 }
        }
    }
}
