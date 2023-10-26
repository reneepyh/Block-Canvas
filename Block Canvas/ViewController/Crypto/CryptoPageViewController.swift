//
//  CryptoPageViewController.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/9/16.
//

import UIKit
import SwiftUI
import SnapKit

class CryptoPageViewController: UIViewController {
    private var ethData = CryptoData()
    
    private var xtzData = CryptoData()
    
    private let apiService = CryptoAPIService.shared
    
    private var previousEthPrice: Double?
    
    private var previousXTZPrice: Double?
    
    private var updateTimer: Timer?
    
    private let ethhostingController = UIHostingController(rootView: ETHPriceChart())
    
    private let xtzhostingController = UIHostingController(rootView: XTZPriceChart())
    
    private let ethLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.main(ofSize: 20)
        label.text = "Ethereum"
        label.textColor = .tertiary
        return label
    }()
    
    private let ethIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let ethPriceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.main(ofSize: 32)
        label.textColor = .secondary
        return label
    }()
    
    private let ethPriceChangeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = UIFont.main(ofSize: 20)
        button.setTitleColor(.secondary, for: .normal)
        button.layer.cornerRadius = 8
        button.isUserInteractionEnabled = false
        button.clipsToBounds = true
        return button
    }()
    
    private let gasFeeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryBlur
        label.text = "-- gwei"
        return label
    }()
    
    private let xtzLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.main(ofSize: 20)
        label.text = "Tezos"
        label.textColor = .tertiary
        return label
    }()
    
    private let xtzIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let xtzPriceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.main(ofSize: 32)
        label.textColor = .secondary
        return label
    }()
    
    private let xtzPriceChangeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = UIFont.main(ofSize: 20)
        button.setTitleColor(.secondary, for: .normal)
        button.layer.cornerRadius = 8
        button.isUserInteractionEnabled = false
        button.clipsToBounds = true
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupETHLabelUI()
        setupETHChartUI()
        setupXTZLabelUI()
        setupXTZChartUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.navigationBar.isHidden = true
        getETHGasFee()
        getETHCurrentPrice()
        getXTZCurrentPrice()
        getETHHistoryPrice()
        getXTZHistoryPrice()
        getETHPriceChange()
        getXTZPriceChange()
        startTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        updateTimer?.invalidate()
        ethData.historyPriceData = []
        xtzData.historyPriceData = []
    }
}

// MARK: - UI Functions
extension CryptoPageViewController {
    private func setupETHLabelUI() {
        view.backgroundColor = .primary
        
        view.addSubview(ethIconImageView)
        ethIconImageView.image = UIImage(named: "ethereum_crypto")
        ethIconImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(6)
            make.leading.equalTo(view.snp.leading).offset(18)
            make.width.equalTo(18)
            make.height.equalTo(18)
        }
        
        view.addSubview(ethLabel)
        ethLabel.snp.makeConstraints { make in
            make.centerY.equalTo(ethIconImageView.snp.centerY)
            make.leading.equalTo(ethIconImageView.snp.trailing).offset(6)
        }
        
        view.addSubview(ethPriceLabel)
        ethPriceLabel.snp.makeConstraints { make in
            make.top.equalTo(ethLabel.snp.bottom).offset(6)
            make.leading.equalTo(view.snp.leading).offset(18)
        }
        
        view.addSubview(ethPriceChangeButton)
        ethPriceChangeButton.snp.makeConstraints { make in
            make.bottom.equalTo(ethPriceLabel.snp.bottom)
            make.trailing.equalTo(view.snp.trailing).offset(-18)
        }
        
        view.addSubview(gasFeeLabel)
        gasFeeLabel.snp.makeConstraints { make in
            make.top.equalTo(ethPriceLabel.snp.bottom).offset(6)
            make.leading.equalTo(view.snp.leading).offset(20)
        }
    }
    
    private func setupETHChartUI() {
        let ethPriceChart = ethhostingController.view
        
        guard let priceChart = ethPriceChart else {
            print("No ETH priceChart.")
            return
        }
        
        addChild(ethhostingController)
        view.addSubview(priceChart)
        
        priceChart.snp.makeConstraints { make in
            make.top.equalTo(gasFeeLabel.snp.bottom).offset(4)
            make.leading.equalTo(view.snp.leading).offset(8)
            make.trailing.equalTo(view.snp.trailing).offset(-8)
            make.height.equalTo(280)
        }
        
        ethhostingController.didMove(toParent: self)
    }
    
    private func setupXTZLabelUI() {
        view.backgroundColor = .primary
        
        view.addSubview(xtzIconImageView)
        xtzIconImageView.image = UIImage(named: "tezos_crypto")
        xtzIconImageView.snp.makeConstraints { make in
            make.top.equalTo(ethhostingController.view.snp.bottom).offset(6)
            make.leading.equalTo(view.snp.leading).offset(18)
            make.width.equalTo(18)
            make.height.equalTo(18)
        }
        
        view.addSubview(xtzLabel)
        xtzLabel.snp.makeConstraints { make in
            make.centerY.equalTo(xtzIconImageView.snp.centerY)
            make.leading.equalTo(xtzIconImageView.snp.trailing).offset(6)
        }
        
        view.addSubview(xtzPriceLabel)
        xtzPriceLabel.snp.makeConstraints { make in
            make.top.equalTo(xtzLabel.snp.bottom).offset(6)
            make.leading.equalTo(view.snp.leading).offset(18)
        }
        
        view.addSubview(xtzPriceChangeButton)
        xtzPriceChangeButton.snp.makeConstraints { make in
            make.bottom.equalTo(xtzPriceLabel.snp.bottom)
            make.trailing.equalTo(view.snp.trailing).offset(-18)
        }
    }
    
    private func setupXTZChartUI() {
        let xtzPriceChart = xtzhostingController.view
        
        guard let priceChart = xtzPriceChart else {
            print("No XTZ priceChart.")
            return
        }
        
        addChild(xtzhostingController)
        view.addSubview(priceChart)
        
        priceChart.snp.makeConstraints { make in
            make.top.equalTo(xtzPriceLabel.snp.bottom).offset(4)
            make.leading.equalTo(view.snp.leading).offset(8)
            make.trailing.equalTo(view.snp.trailing).offset(-8)
            make.bottom.greaterThanOrEqualTo(view.snp.bottom).offset(-10)
            make.height.greaterThanOrEqualTo(150)
        }
        
        xtzhostingController.didMove(toParent: self)
    }
    
    private func animatePriceLabelColor(to color: UIColor) {
        DispatchQueue.main.async {
            // Change the color immediately to the new value
            self.ethPriceLabel.textColor = color
            
            // After a delay, fade back to black
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                UIView.transition(with: self.ethPriceLabel, duration: 0.5, options: .transitionCrossDissolve, animations: {
                    self.ethPriceLabel.textColor = .secondary
                }, completion: nil)
            }
        }
    }
    
    // remove access control for the purpose of unit test
    func configurationForPriceChange(_ priceChange: Double) -> UIButton.Configuration {
        var config = UIButton.Configuration.filled()
        config.title = "\(priceChange)%"
        let size = UIImage.SymbolConfiguration(pointSize: 8)
        config.titlePadding = 4
        config.imagePadding = 4
        config.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 6, bottom: 4, trailing: 6)
        
        if priceChange > 0 {
            config.image = UIImage(systemName: "arrowtriangle.up.fill", withConfiguration: size)
            config.background.backgroundColor = .systemGreen
        } else if priceChange < 0 {
            config.image = UIImage(systemName: "arrowtriangle.down.fill", withConfiguration: size)
            config.background.backgroundColor = .systemPink
        } else {
            config.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)
            config.background.backgroundColor = .black
        }
        
        return config
    }
    
    private func updateETHButtonConfiguration(for priceChange: Double) {
        ethPriceChangeButton.configuration = configurationForPriceChange(priceChange)
    }
    
    private func updateXTZButtonConfiguration(for priceChange: Double) {
        xtzPriceChangeButton.configuration = configurationForPriceChange(priceChange)
    }
}

// MARK: - API Functions
extension CryptoPageViewController {
    private func getETHCurrentPrice() {
        apiService.getCurrentPrice(for: .ETH) { [weak self] result in
            switch result {
            case .success(let doubledCurrentPrice):
                let floored = floor(doubledCurrentPrice * 100) / 100
                self?.ethData.currentPrice = "US$\(String(floored))"
                
                if let previousEthPrice = self?.previousEthPrice {
                    if doubledCurrentPrice > previousEthPrice {
                        self?.animatePriceLabelColor(to: .systemGreen)
                    } else if doubledCurrentPrice < previousEthPrice {
                        self?.animatePriceLabelColor(to: .systemPink)
                    }
                }
                self?.previousEthPrice = doubledCurrentPrice
                DispatchQueue.main.async { [weak self] in
                    self?.ethPriceLabel.text = self?.ethData.currentPrice
                }
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func getXTZCurrentPrice() {
        apiService.getCurrentPrice(for: .XTZ) { [weak self] result in
            switch result {
            case .success(let doubledCurrentPrice):
                let floored = floor(doubledCurrentPrice * 100) / 100
                self?.xtzData.currentPrice = "US$\(String(floored))"
                
                if let previousXTZPrice = self?.previousXTZPrice {
                    if doubledCurrentPrice > previousXTZPrice {
                        self?.animatePriceLabelColor(to: .systemGreen)
                    } else if doubledCurrentPrice < previousXTZPrice {
                        self?.animatePriceLabelColor(to: .systemPink)
                    }
                }
                self?.previousXTZPrice = doubledCurrentPrice
                DispatchQueue.main.async { [weak self] in
                    self?.xtzPriceLabel.text = self?.xtzData.currentPrice
                }
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func getETHPriceChange() {
        apiService.getPriceChange(for: .ETH) { [weak self] result in
            switch result {
            case .success(let priceChange):
                self?.ethData.priceChange = String(priceChange)
                DispatchQueue.main.async { [weak self] in
                    if let priceChange = self?.ethData.priceChange, let change = Double(priceChange) {
                        self?.updateETHButtonConfiguration(for: change)
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func getXTZPriceChange() {
        apiService.getPriceChange(for: .XTZ) { [weak self] result in
            switch result {
            case .success(let priceChange):
                self?.xtzData.priceChange = String(priceChange)
                DispatchQueue.main.async { [weak self] in
                    if let priceChange = self?.xtzData.priceChange, let change = Double(priceChange) {
                        self?.updateXTZButtonConfiguration(for: change)
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func getETHGasFee() {
        apiService.getGasFee { [weak self] result in
            switch result {
            case .success(let gasFee):
                self?.ethData.gasFee = gasFee
                DispatchQueue.main.async { [weak self] in
                    self?.gasFeeLabel.text = self?.ethData.gasFee
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func getETHHistoryPrice() {
        apiService.getHistoryPrice(for: .ETH) { [weak self] result in
            switch result {
            case .success(let historyPriceData):
                self?.ethData.historyPriceData = historyPriceData
                DispatchQueue.main.async { [weak self] in
                    guard let ethPriceData = self?.ethData.historyPriceData else {
                        print("Cannot fetch ethPriceData.")
                        BCProgressHUD.showFailure()
                        return
                    }
                    self?.ethhostingController.rootView = ETHPriceChart(ethPriceData: ethPriceData)
                }
            case .failure(let error):
                print("Error fetching history price data: \(error.localizedDescription)")
            }
        }
    }
    
    private func getXTZHistoryPrice() {
        apiService.getHistoryPrice(for: .XTZ) { [weak self] result in
            switch result {
            case .success(let historyPriceData):
                self?.xtzData.historyPriceData = historyPriceData
                DispatchQueue.main.async { [weak self] in
                    guard let xtzPriceData = self?.xtzData.historyPriceData else {
                        print("Cannot fetch xtzPriceData.")
                        BCProgressHUD.showFailure()
                        return
                    }
                    self?.xtzhostingController.rootView = XTZPriceChart(xtzPriceData: xtzPriceData)
                }
            case .failure(let error):
                print("Error fetching history price data: \(error.localizedDescription)")
            }
        }
    }
    
    private func startTimer() {
        updateTimer?.invalidate()
        updateTimer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(updatePriceLabel), userInfo: nil, repeats: true)
    }
    
    @objc func updatePriceLabel() {
        print("4秒重抓")
        getETHCurrentPrice()
        getETHPriceChange()
        getETHGasFee()
        getXTZCurrentPrice()
        getXTZPriceChange()
    }
}
