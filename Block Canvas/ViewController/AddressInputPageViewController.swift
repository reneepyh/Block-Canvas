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
    
    private var ethWallets: [[String: String]] = []
    
    private let addressTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .systemGray4
        textField.font = UIFont(name: "PingFang TC", size: CGFloat(16))
        textField.textColor = UIColor.black
        textField.placeholder = "Enter wallet address"
        textField.borderStyle = .roundedRect
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .done
        return textField
    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .systemGray4
        textField.font = UIFont(name: "PingFang TC", size: CGFloat(16))
        textField.textColor = UIColor.black
        textField.placeholder = "Give this wallet a name"
        textField.borderStyle = .roundedRect
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .done
        return textField
    }()
    
    private let continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Continue", for: .normal)
        button.tintColor = .systemGray2
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.layer.cornerRadius = 10
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addressTextField.delegate = self
        nameTextField.delegate = self
        layout()
        findEthWallets()
    }
    
    private func layout() {
        view.addSubview(addressTextField)
        view.addSubview(continueButton)
        view.addSubview(nameTextField)
        addressTextField.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top).offset(100)
            make.left.equalTo(view.snp.left).offset(16)
            make.right.equalTo(view.snp.right).offset(-16)
        }
        nameTextField.snp.makeConstraints { make in
            make.top.equalTo(addressTextField.snp.bottom).offset(12)
            make.left.equalTo(view.snp.left).offset(16)
            make.right.equalTo(view.snp.right).offset(-16)
        }
        continueButton.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(nameTextField.snp.bottom).offset(30)
        }
        continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
    }
    
    private func findEthWallets() {
        ethWallets = userDefaults.object(forKey: "ethWallets") as? [[String: String]] ?? []
    }
    
    @objc func continueButtonTapped() {
        guard let address = addressTextField.text, !address.isEmpty,
        let walletName = nameTextField.text, !walletName.isEmpty else {
            print("User did not enter address or wallet name")
            return
        }
        let walletInfo = ["address": address, "name": walletName]
        ethWallets.append(walletInfo)
        userDefaults.set(ethWallets, forKey: "ethWallets")
        
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
