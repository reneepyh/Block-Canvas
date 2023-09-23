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
    
    private var updateTimer: Timer?
    
    private let hostingController = UIHostingController(rootView: EthPriceChart())
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 48)
        return label
    }()
    
    private let priceChangeLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 20)
        return label
    }()
    
    private let gasFeeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20)
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
                    let doubled = Double(ethCurrentPrice.price)
                    let floored = floor((doubled ?? 0) * 100) / 100
                    self?.ethCurrentPrice = String(floored)
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
                    self?.priceChangeLabel.text = self?.ethPriceChange
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
        view.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top).offset(100)
            make.left.equalTo(view.snp.left).offset(16)
        }
        
        view.addSubview(priceChangeLabel)
        priceChangeLabel.snp.makeConstraints { make in
            make.bottom.equalTo(priceLabel)
            make.right.equalTo(view.snp.right).offset(-16)
        }
        
        view.addSubview(gasFeeLabel)
        gasFeeLabel.snp.makeConstraints { make in
            make.top.equalTo(priceLabel.snp.bottom).offset(-4)
            make.left.equalTo(view.snp.left).offset(18)
            make.bottom.equalTo(view.snp.top).offset(200)
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
            make.top.equalTo(gasFeeLabel.snp.bottom)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.bottom.equalTo(view.snp.bottom).offset(-100)
        }
        
        hostingController.didMove(toParent: self)
    }
    
    @objc func updatePriceLabel() {
        print("4秒重抓")
        getETHCurrentPrice()
        getETHPriceChange()
        getEthGasFee()
    }
    
}
