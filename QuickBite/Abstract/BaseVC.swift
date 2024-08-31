//
//  BaseVC.swift
//  QuickBite
//
//  Created by 장예지 on 8/14/24.
//

import UIKit
import RxSwift
import RxCocoa
import Toast

class BaseVC: UIViewController {
    
    private var isChild: Bool = false
    
    let disposeBag = DisposeBag()
    
    init(title: String? = nil, isChild: Bool = false){
        super.init(nibName: nil, bundle: nil)
        self.isChild = isChild
        self.navigationItem.title = title
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .white

        if isChild {
            navigationController?.navigationBar.titleTextAttributes = [.foregroundColor : Color.primaryColor, .font: Font.boldFont(.smallLarge)]
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: ImageAssets.leftArrow, style: .done, target: self, action: #selector(dismissButtonTapped))
            navigationItem.leftBarButtonItem?.tintColor = Color.primaryColor
        }

        configureHierarchy()
        configureLayout()
        configureUI()
        bind()
    }
    
    deinit {
        print("\(String(describing: type(of: self))) deinitialized")
    }
    
    func configureHierarchy(){ }
    
    func configureLayout(){ }
    
    func configureUI(){ }
    
    func bind(){ }
    
    func showToastMsg(msg: String){
        view.hideAllToasts()
        DispatchQueue.main.async {
            if let vc = UIApplication.shared.keyWindow?.visibleViewController as? UIViewController {
                vc.view.makeToast(msg)
            }
            
        }
    }
    
    @objc private func dismissButtonTapped(){
        if isChild {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true)
        }
    }
    
    func showAlert(title: String, message: String? = nil) -> Single<AlertType> {
        return Single<AlertType>.create { [weak self] single in
            guard let self else { return Disposables.create() }
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            let confirm = UIAlertAction(title: "확인", style: .default) { _ in
                single(.success(.ok))
            }
            let cancel = UIAlertAction(title: "취소", style: .cancel) { _ in
                single(.success(.cancel))
            }
            
            alert.addAction(confirm)
            alert.addAction(cancel)
            
            present(alert, animated: true)
            return Disposables.create()
        }
    }
}
