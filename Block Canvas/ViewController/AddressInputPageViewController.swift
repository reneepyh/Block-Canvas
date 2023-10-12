//
//  PortfolioPageViewController.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/9/15.
//

import UIKit
import SnapKit

class AddressInputPageViewController: UIViewController {
    private let userDefaults = UserDefaults.standard
    
    private var walletAddresses: [[String: String]] = []
    
    private let addressTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .secondaryBlur
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.textColor = .primary
        textField.tintColor = .primary
        textField.attributedPlaceholder = NSAttributedString(string: "Enter Ethereum or Tezos address", attributes: [NSAttributedString.Key.foregroundColor: UIColor.primary])
        textField.borderStyle = .roundedRect
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .done
        return textField
    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .secondaryBlur
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.textColor = .primary
        textField.tintColor = .primary
        textField.attributedPlaceholder = NSAttributedString(string: "Give this address a name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.primary])
        textField.borderStyle = .roundedRect
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .done
        return textField
    }()
    
    private let continueButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Continue", for: .normal)
        button.setTitleColor(.primary, for: .normal)
        button.titleLabel?.font = UIFont.main(ofSize: 16)
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .capsule
        config.background.backgroundColor = .tertiary
        button.configuration = config
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        findWallets()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavTab()
    }
    
    private func setupUI() {
        view.backgroundColor = .primary
        self.title = "add Wallet."
        
        view.addSubview(addressTextField)
        view.addSubview(continueButton)
        view.addSubview(nameTextField)
        addressTextField.delegate = self
        nameTextField.delegate = self
        
        addressTextField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(50)
            make.leading.equalTo(view.snp.leading).offset(16)
            make.trailing.equalTo(view.snp.trailing).offset(-16)
            make.height.equalTo(40)
        }
        nameTextField.snp.makeConstraints { make in
            make.top.equalTo(addressTextField.snp.bottom).offset(16)
            make.leading.equalTo(view.snp.leading).offset(16)
            make.trailing.equalTo(view.snp.trailing).offset(-16)
            make.height.equalTo(40)
        }
        continueButton.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.bottom.equalTo(view.snp.bottom).offset(-70)
            make.width.equalTo(view.snp.width).multipliedBy(0.9)
            make.height.equalTo(40)
        }
        continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        
        addressTextField.clearButtonMode = .unlessEditing
        addressTextField.autocapitalizationType = .none
        addressTextField.autocorrectionType = .no
        
        nameTextField.clearButtonMode = .unlessEditing
        nameTextField.autocapitalizationType = .none
        nameTextField.autocorrectionType = .no
    }
    
    private func setupNavTab() {
        let navigationBar = self.navigationController?.navigationBar
        navigationController?.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = .primary
        navigationBarAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.secondary, NSAttributedString.Key.font: UIFont.main(ofSize: 16)]
        navigationBarAppearance.shadowColor = .clear
        navigationBar?.standardAppearance = navigationBarAppearance
        navigationBar?.scrollEdgeAppearance = navigationBarAppearance
        
        tabBarController?.tabBar.isHidden = true
    }
    
    private func findWallets() {
        walletAddresses = userDefaults.object(forKey: "walletAddress") as? [[String: String]] ?? []
    }
    
    @objc func continueButtonTapped() {
        guard let address = addressTextField.text, (address.hasPrefix("0x") || address.hasPrefix("tz") || (address.hasPrefix("tx"))) else {
            print("User did not enter valid address")
            BCProgressHUD.showFailure(text: "Address is not valid.")
            return
        }
        
        guard let walletName = nameTextField.text, !walletName.isEmpty else {
            print("User did not enter wallet name")
            BCProgressHUD.showFailure(text: "Wallet name empty.")
            return
        }
        
        let walletInfo = ["address": address, "name": walletName]
        walletAddresses.append(walletInfo)
        userDefaults.set(walletAddresses, forKey: "walletAddress")
        
        guard
            let portfolioListVC = UIStoryboard.portfolio.instantiateViewController(
                withIdentifier: String(describing: PortfolioListViewController.self)
            ) as? PortfolioListViewController
        else {
            return
        }
        portfolioListVC.modalPresentationStyle = .overFullScreen
        navigationController?.pushViewController(portfolioListVC, animated: true)
        portfolioListVC.navigationItem.hidesBackButton = true
    }
}

extension AddressInputPageViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == addressTextField {
            nameTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            self.view.endEditing(true)
        }
}
