//
//  PortfolioDisplayViewController.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/9/17.
//

import UIKit
import SwiftUI
import SnapKit

class PortfolioDisplayViewController: UIViewController {
    private let backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "chevron.backward")?.withTintColor(.secondary, renderingMode: .alwaysOriginal), for: .normal)
        return button
    }()
    
    private let apiService = PortfolioAPIService.shared
    
    var nftInfoForDisplay: [NFTInfoForDisplay]?
    
    var walletAddress: String?
    
    private var userNFTs: [String] = []
    
    private let userDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getNFTsByWallet()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupNavTab()
    }
}

// MARK: - UI Functions
extension PortfolioDisplayViewController {
    private func setupUI() {
        view.backgroundColor = .primary
        view.addSubview(backButton)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(6)
            make.leading.equalToSuperview().offset(12)
            make.width.equalTo(16)
        }
    }
    
    private func setupNavTab() {
        navigationController?.navigationBar.isHidden = true
        tabBarController?.tabBar.isHidden = true
    }
    
    private func setupDisplay() {
        guard let nftInfoForDisplay = nftInfoForDisplay else {
            print("Cannot create imageURLs.")
            return
        }
        
        let hostingController = UIHostingController(rootView: PortfolioDisplay(nfts: nftInfoForDisplay))
        hostingController.rootView.onARButtonTap = { selectedImageURL in
            self.viewInARButtonTapped(with: selectedImageURL)
        }
        
        addChild(hostingController)
        view.addSubview(hostingController.view)
        
        let portfolioDisplayView = hostingController.view
        
        guard let portfolioDisplayView = portfolioDisplayView else {
            print("No portfolio display view.")
            return
        }
        
        portfolioDisplayView.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(8)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        hostingController.didMove(toParent: self)
    }
    
    func viewInARButtonTapped(with url: URL) {
        BCProgressHUD.show()
        let arViewController = ARDisplayViewController()
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error downloading image: \(error)")
            } else if let data = data, let image = UIImage(data: data) {
                arViewController.imageToDisplay = image
                DispatchQueue.main.async {
                    arViewController.modalPresentationStyle = .overFullScreen
                    BCProgressHUD.dismiss()
                    self.present(arViewController, animated: true, completion: nil)
                }
            }
        }
        task.resume()
    }
    
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - API Functions
extension PortfolioDisplayViewController {
    private func getNFTsByWallet() {
        BCProgressHUD.show()
        
        guard let address = walletAddress else {
            handleFailure(message: "No address.")
            return
        }
        
        apiService.getNFTsByWallet(walletAddress: address) { [weak self] nftInfoForDisplay, error in
                if let error = error {
                    self?.handleFailure(message: error.localizedDescription)
                } else {
                    self?.nftInfoForDisplay = nftInfoForDisplay
                    self?.updateUserNFTs()
                    DispatchQueue.main.async { [weak self] in
                        self?.setupDisplay()
                    }
                }
                BCProgressHUD.dismiss()
            }
    }
    
    private func handleFailure(message: String) {
        print(message)
        BCProgressHUD.showFailure(text: BCConstant.addressError)
    }
    
    private func updateUserNFTs() {
        self.userNFTs = self.nftInfoForDisplay?.map { $0.title } ?? []
        self.userDefaults.set(self.userNFTs, forKey: "userNFTs")
    }
}
