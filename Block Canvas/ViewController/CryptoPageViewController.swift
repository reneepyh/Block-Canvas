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
    private var ethPriceData: [EthHistoryPriceData] = []
    
    private var ethCurrentPrice: String?
    
    private var ethPriceChange: String?
    
    private var ethGasFee: String?
    
    private var previousEthPrice: Double?
    
    private var updateTimer: Timer?
    
    private let hostingController = UIHostingController(rootView: EthPriceChart())
    
    private let ethLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 20)
        label.text = "Ethereum"
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 38)
        return label
    }()
    
    private let priceChangeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.isUserInteractionEnabled = false
        button.clipsToBounds = true
        return button
    }()
    
    private let gasFeeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLabelUI()
        setupChartUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        getETHCurrentPrice()
        getEthHistoryPrice()
        getETHPriceChange()
        getEthGasFee()
        startTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        updateTimer?.invalidate()
        ethPriceData = []
    }
    
    private func startTimer() {
        updateTimer?.invalidate()
        updateTimer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(updatePriceLabel), userInfo: nil, repeats: true)
    }
    
    private func getETHCurrentPrice() {
        let apiKey = Bundle.main.object(forInfoDictionaryKey: "Binance_API_Key") as? String
        
        guard let key = apiKey, !key.isEmpty else {
            print("Binance API key does not exist.")
            return
        }
        
        if let url = URL(string: "https://api1.binance.com/api/v3/ticker/price?symbol=ETHUSDT") {
            
            var request = URLRequest(url: url)
            request.setValue(apiKey, forHTTPHeaderField: "X-MBX-APIKEY")
            request.httpMethod = "GET"
            
            let session = URLSession.shared
            
            let task = session.dataTask(with: request) { [weak self] data, response, error in
                if let error = error {
                    print(error)
                    return
                }
                
                guard let data = data else {
                    print("No data.")
                    return
                }
                
                let decoder = JSONDecoder()
                
                do {
                    let ethCurrentPrice = try decoder.decode(EthCurrentPriceData.self, from: data)
                    let doubledCurrentPrice = Double(ethCurrentPrice.price)
                    let floored = floor((doubledCurrentPrice ?? 0) * 100) / 100
                    self?.ethCurrentPrice = "US$\(String(floored))"
                    
                    if let previousEthPrice = self?.previousEthPrice {
                        if let doubledCurrentPrice = doubledCurrentPrice {
                            if doubledCurrentPrice > previousEthPrice {
                                self?.animatePriceLabelColor(to: .systemGreen)
                            } else if doubledCurrentPrice < previousEthPrice {
                                self?.animatePriceLabelColor(to: .systemPink)
                            }
                        }
                    }
                    self?.previousEthPrice = doubledCurrentPrice
                }
                catch {
                    print("Error in JSON decoding.")
                }
                DispatchQueue.main.async { [weak self] in
                    self?.priceLabel.text = self?.ethCurrentPrice
                }
            }
            task.resume()
        }
        else {
            print("Invalid URL.")
        }
    }
    
    private func getETHPriceChange() {
        let apiKey = Bundle.main.object(forInfoDictionaryKey: "Binance_API_Key") as? String
        
        guard let key = apiKey, !key.isEmpty else {
            print("Binance API key does not exist.")
            return
        }
        
        if let url = URL(string: "https://api1.binance.com/api/v3/ticker/24hr?symbol=ETHUSDT") {
            
            var request = URLRequest(url: url)
            request.setValue(apiKey, forHTTPHeaderField: "X-MBX-APIKEY")
            request.httpMethod = "GET"
            
            let session = URLSession.shared
            
            let task = session.dataTask(with: request) { [weak self] data, response, error in
                if let error = error {
                    print(error)
                    return
                }
                
                guard let data = data else {
                    print("No data.")
                    return
                }
                
                let decoder = JSONDecoder()
                
                do {
                    let ethCurrentPrice = try decoder.decode(EthPriceChange.self, from: data)
                    let doubled = Double(ethCurrentPrice.priceChangePercent)
                    let floored = floor((doubled ?? 0) * 100) / 100
                    self?.ethPriceChange = String(floored)
                }
                catch {
                    print("Error in JSON decoding.")
                }
                DispatchQueue.main.async { [weak self] in
                    if let priceChange = self?.ethPriceChange, let change = Double(priceChange) {
                        if change > 0 {
                            var config = UIButton.Configuration.filled()
                            config.title = "\(priceChange)%"
                            let size = UIImage.SymbolConfiguration(pointSize: 8)
                            config.image = UIImage(systemName: "arrowtriangle.up.fill", withConfiguration: size)
                            config.titlePadding = 4
                            config.imagePadding = 4
                            config.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 6, bottom: 4, trailing: 6)
                            config.background.backgroundColor = .systemGreen
                            self?.priceChangeButton.configuration = config
                        } else if change < 0 {
                            var config = UIButton.Configuration.filled()
                            config.title = "\(priceChange)%"
                            let size = UIImage.SymbolConfiguration(pointSize: 8)
                            config.image = UIImage(systemName: "arrowtriangle.up.fill", withConfiguration: size)
                            config.titlePadding = 4
                            config.imagePadding = 4
                            config.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 6, bottom: 4, trailing: 6)
                            config.background.backgroundColor = .systemRed
                            self?.priceChangeButton.configuration = config
                        } else {
                            var config = UIButton.Configuration.filled()
                            config.title = "\(priceChange)%"
                            config.titlePadding = 4
                            config.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)
                            config.background.backgroundColor = .black
                            self?.priceChangeButton.configuration = config
                        }
                    }
                }
            }
            task.resume()
        }
        else {
            print("Invalid URL.")
        }
    }
    
    private func getEthGasFee() {
        let apiKey = Bundle.main.object(forInfoDictionaryKey: "Etherscan_API_Key") as? String
        
        guard let key = apiKey, !key.isEmpty else {
            print("Etherscan API Key does not exist.")
            return
        }
        
        if let url = URL(string: "https://api.etherscan.io/api?module=gastracker&action=gasoracle&apikey=\(key)") {
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            let session = URLSession.shared
            
            let task = session.dataTask(with: request) { [weak self] data, response, error in
                if let error = error {
                    print(error)
                    return
                }
                
                guard let data = data else {
                    print("No data.")
                    return
                }
                
                let decoder = JSONDecoder()
                
                do {
                    let ethGasFee = try decoder.decode(EthGasFee.self, from: data)
                    self?.ethGasFee = "\(ethGasFee.result?.proposeGasPrice ?? "") gwei"
                }
                catch {
                    print("Error in JSON decoding.")
                }
                DispatchQueue.main.async { [weak self] in
                    self?.gasFeeLabel.text = self?.ethGasFee
                }
            }
            task.resume()
        }
        else {
            print("Invalid URL.")
        }
    }
    
    private func getEthHistoryPrice() {
        BCProgressHUD.show()
        if let url = URL(string: "https://api.coincap.io/v2/assets/ethereum/history?interval=m1") {
            var request = URLRequest(url: url)
            request.setValue("deflate", forHTTPHeaderField: "Accept-Encoding")
            request.httpMethod = "GET"
            
            let session = URLSession.shared
            
            let task = session.dataTask(with: request) { [weak self] data, response, error in
                if let error = error {
                    print(error)
                    BCProgressHUD.showFailure()
                    return
                }
                
                guard let data = data else {
                    print("No data.")
                    BCProgressHUD.showFailure()
                    return
                }
                
                let decoder = JSONDecoder()
                
                do {
                    let ethPrice = try decoder.decode(EthHistoryPrice.self, from: data)
                    for ethPriceData in ethPrice.data {
                        let unixTimestampSeconds = Double(ethPriceData.time) / 1000.0
                        let date = Date(timeIntervalSince1970: unixTimestampSeconds)
                        self?.ethPriceData.append(EthHistoryPriceData(price: Double(ethPriceData.priceUsd) ?? 0, time: date))
                    }
                }
                catch {
                    print("Error in JSON decoding.")
                }
                DispatchQueue.main.async { [weak self] in
                    guard let ethPriceData = self?.ethPriceData else {
                        print("Cannot fetch ethPriceData.")
                        BCProgressHUD.showFailure()
                        return
                    }
                    self?.hostingController.rootView = EthPriceChart(ethPriceData: ethPriceData)
                    BCProgressHUD.dismiss()
                }
            }
            task.resume()
        }
        else {
            print("Invalid URL.")
        }
        
    }
    
    private func setupLabelUI() {
        view.addSubview(ethLabel)
        ethLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(4)
            make.left.equalTo(view.snp.left).offset(16)
        }
        
        view.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(ethLabel.snp.bottom).offset(4)
            make.left.equalTo(view.snp.left).offset(16)
        }
        
        view.addSubview(priceChangeButton)
        priceChangeButton.snp.makeConstraints { make in
            make.bottom.equalTo(priceLabel.snp.bottom)
            make.right.equalTo(view.snp.right).offset(-16)
        }
        
        view.addSubview(gasFeeLabel)
        gasFeeLabel.snp.makeConstraints { make in
            make.top.equalTo(priceLabel.snp.bottom).offset(4)
            make.left.equalTo(view.snp.left).offset(18)
        }
    }
    
    private func setupChartUI() {
        let ethPriceChart = hostingController.view
        
        guard let ethPriceChart = ethPriceChart else {
            print("No ethPriceChart.")
            return
        }
        
        addChild(hostingController)
        view.addSubview(ethPriceChart)
        
        ethPriceChart.snp.makeConstraints { make in
            make.top.equalTo(gasFeeLabel.snp.bottom).offset(8)
            make.left.equalTo(view.snp.left).offset(8)
            make.right.equalTo(view.snp.right).offset(-8)
            make.bottom.equalTo(view.snp.bottom).offset(-100)
            make.height.greaterThanOrEqualTo(350)
        }
        
        hostingController.didMove(toParent: self)
    }
    
    private func animatePriceLabelColor(to color: UIColor) {
        DispatchQueue.main.async {
            // Change the color immediately to the new value
            self.priceLabel.textColor = color
            
            // After a delay, fade back to black
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                UIView.transition(with: self.priceLabel, duration: 0.5, options: .transitionCrossDissolve, animations: {
                    self.priceLabel.textColor = .label
                }, completion: nil)
            }
        }
    }
    
    @objc func updatePriceLabel() {
        print("4秒重抓")
        getETHCurrentPrice()
        getETHPriceChange()
        getEthGasFee()
    }
    
}
