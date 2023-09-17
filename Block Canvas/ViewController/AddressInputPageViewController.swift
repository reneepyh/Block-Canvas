//
//  PortfolioPageViewController.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/9/15.
//

import UIKit
import SnapKit

class AddressInputPageViewController: UIViewController {
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
    
    private let continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Continue", for: .normal)
        button.tintColor = .black
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.cornerRadius = 10
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
    }
    
    private func layout() {
        view.addSubview(addressTextField)
        view.addSubview(continueButton)
        addressTextField.snp.makeConstraints { make in
            make.center.equalTo(view)
        }
        continueButton.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(addressTextField.snp.bottom).offset(30)
        }
        
        continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
    }
    
    @objc func continueButtonTapped() {
        guard let address = addressTextField.text, !address.isEmpty else {
            print("User did not enter address")
            return
        }
        performSegue(withIdentifier: "showPortfolio", sender: address)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPortfolio" {
            let portfolioVC = segue.destination as? PortfolioDisplayViewController
            portfolioVC?.ethAddress = sender as? String
        }
    }
}
