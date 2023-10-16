//
//  CryptoPageViewController.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/9/16.
//

import UIKit
import SwiftUI
import SnapKit
// swiftlint: disable type_body_length
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
    
    private func startTimer() {
        updateTimer?.invalidate()
        updateTimer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(updatePriceLabel), userInfo: nil, repeats: true)
    }
    
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
        apiService.getCurrentPrice(for: .XYZ) { [weak self] result in
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
                    let ethPriceChange = try decoder.decode(CryptoPriceChange.self, from: data)
                    let doubled = Double(ethPriceChange.priceChangePercent)
                    let floored = floor((doubled ?? 0) * 100) / 100
                    self?.ethData.priceChange = String(floored)
                }
                catch {
                    print("Error in JSON decoding.")
                }
                DispatchQueue.main.async { [weak self] in
                    if let priceChange = self?.ethData.priceChange, let change = Double(priceChange) {
                        if change > 0 {
                            var config = UIButton.Configuration.filled()
                            config.title = "\(priceChange)%"
                            let size = UIImage.SymbolConfiguration(pointSize: 8)
                            config.image = UIImage(systemName: "arrowtriangle.up.fill", withConfiguration: size)
                            config.titlePadding = 4
                            config.imagePadding = 4
                            config.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 6, bottom: 4, trailing: 6)
                            config.background.backgroundColor = .systemGreen
                            self?.ethPriceChangeButton.configuration = config
                        } else if change < 0 {
                            var config = UIButton.Configuration.filled()
                            config.title = "\(priceChange)%"
                            let size = UIImage.SymbolConfiguration(pointSize: 8)
                            config.image = UIImage(systemName: "arrowtriangle.down.fill", withConfiguration: size)
                            config.titlePadding = 4
                            config.imagePadding = 4
                            config.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 6, bottom: 4, trailing: 6)
                            config.background.backgroundColor = .systemPink
                            self?.ethPriceChangeButton.configuration = config
                        } else {
                            var config = UIButton.Configuration.filled()
                            config.title = "\(priceChange)%"
                            config.titlePadding = 4
                            config.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)
                            config.background.backgroundColor = .black
                            self?.ethPriceChangeButton.configuration = config
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
    
    private func getXTZPriceChange() {
        let apiKey = Bundle.main.object(forInfoDictionaryKey: "Binance_API_Key") as? String
        
        guard let key = apiKey, !key.isEmpty else {
            print("Binance API key does not exist.")
            return
        }
        
        if let url = URL(string: "https://api1.binance.com/api/v3/ticker/24hr?symbol=XTZUSDT") {
            
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
                    let xtzPriceChange = try decoder.decode(CryptoPriceChange.self, from: data)
                    let doubled = Double(xtzPriceChange.priceChangePercent)
                    let floored = floor((doubled ?? 0) * 100) / 100
                    self?.xtzData.priceChange = String(floored)
                }
                catch {
                    print("Error in JSON decoding.")
                }
                DispatchQueue.main.async { [weak self] in
                    if let priceChange = self?.xtzData.priceChange, let change = Double(priceChange) {
                        if change > 0 {
                            var config = UIButton.Configuration.filled()
                            config.title = "\(priceChange)%"
                            let size = UIImage.SymbolConfiguration(pointSize: 8)
                            config.image = UIImage(systemName: "arrowtriangle.up.fill", withConfiguration: size)
                            config.titlePadding = 4
                            config.imagePadding = 4
                            config.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 6, bottom: 4, trailing: 6)
                            config.background.backgroundColor = .systemGreen
                            self?.xtzPriceChangeButton.configuration = config
                        } else if change < 0 {
                            var config = UIButton.Configuration.filled()
                            config.title = "\(priceChange)%"
                            let size = UIImage.SymbolConfiguration(pointSize: 8)
                            config.image = UIImage(systemName: "arrowtriangle.down.fill", withConfiguration: size)
                            config.titlePadding = 4
                            config.imagePadding = 4
                            config.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 6, bottom: 4, trailing: 6)
                            config.background.backgroundColor = .systemPink
                            self?.xtzPriceChangeButton.configuration = config
                        } else {
                            var config = UIButton.Configuration.filled()
                            config.title = "\(priceChange)%"
                            config.titlePadding = 4
                            config.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)
                            config.background.backgroundColor = .black
                            self?.xtzPriceChangeButton.configuration = config
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
    
    private func getETHGasFee() {
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
                    self?.ethData.gasFee = "\(ethGasFee.result?.proposeGasPrice ?? "") gwei"
                }
                catch {
                    print("Error in JSON decoding.")
                }
                DispatchQueue.main.async { [weak self] in
                    self?.gasFeeLabel.text = self?.ethData.gasFee
                }
            }
            task.resume()
        }
        else {
            print("Invalid URL.")
        }
    }
    
    private func getETHHistoryPrice() {
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
                    let ethPrice = try decoder.decode(CryptoHistoryPrice.self, from: data)
                    for ethPriceData in ethPrice.data {
                        let unixTimestampSeconds = Double(ethPriceData.time) / 1000.0
                        let date = Date(timeIntervalSince1970: unixTimestampSeconds)
                        self?.ethData.historyPriceData.append(HistoryPriceData(price: Double(ethPriceData.priceUsd) ?? 0, time: date))
                    }
                }
                catch {
                    print("Error in JSON decoding.")
                }
                DispatchQueue.main.async { [weak self] in
                    guard let ethPriceData = self?.ethData.historyPriceData else {
                        print("Cannot fetch ethPriceData.")
                        BCProgressHUD.showFailure()
                        return
                    }
                    self?.ethhostingController.rootView = ETHPriceChart(ethPriceData: ethPriceData)
                    BCProgressHUD.dismiss()
                }
            }
            task.resume()
        }
        else {
            print("Invalid URL.")
        }
    }
    
    private func getXTZHistoryPrice() {
        BCProgressHUD.show()
        if let url = URL(string: "https://api.coincap.io/v2/assets/tezos/history?interval=m1") {
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
                    let xtzPrice = try decoder.decode(CryptoHistoryPrice.self, from: data)
                    for xtzPriceData in xtzPrice.data {
                        let unixTimestampSeconds = Double(xtzPriceData.time) / 1000.0
                        let date = Date(timeIntervalSince1970: unixTimestampSeconds)
                        self?.xtzData.historyPriceData.append(HistoryPriceData(price: Double(xtzPriceData.priceUsd) ?? 0, time: date))
                    }
                }
                catch {
                    print("Error in JSON decoding.")
                }
                DispatchQueue.main.async { [weak self] in
                    guard let xtzPriceData = self?.xtzData.historyPriceData else {
                        print("Cannot fetch xtzPriceData.")
                        BCProgressHUD.showFailure()
                        return
                    }
                    self?.xtzhostingController.rootView = XTZPriceChart(xtzPriceData: xtzPriceData)
                    BCProgressHUD.dismiss()
                }
            }
            task.resume()
        }
        else {
            print("Invalid URL.")
        }
        
    }
    
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
    
    @objc func updatePriceLabel() {
        print("4秒重抓")
        getETHCurrentPrice()
        getETHPriceChange()
        getETHGasFee()
        getXTZCurrentPrice()
        getXTZPriceChange()
    }
}
