//
//  WidegtWalletSelectedViewController.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/10/1.
//

import UIKit
import SnapKit
import Lottie

class WidgetWalletSelectedViewController: UIViewController {
    private var animationView: LottieAnimationView?
    
    private let greatLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 32)
        label.textColor = .tertiary
        label.text = "Great!"
        return label
    }()
    
    private let instructionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.textColor = .secondary
        label.text = "Go to the home screen and choose an NFT for the widget."
        label.textAlignment = .center
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAnimation()
    }
}

// MARK: - UI Functions
extension WidgetWalletSelectedViewController {
    private func setupUI() {
        view.backgroundColor  = .primary
        view.addSubview(greatLabel)
        greatLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(30)
            make.centerX.equalTo(view.snp.centerX)
        }
        
        view.addSubview(instructionLabel)
        instructionLabel.snp.makeConstraints { make in
            make.top.equalTo(greatLabel.snp.bottom).offset(16)
            make.leading.equalTo(view.snp.leading).offset(32)
            make.trailing.equalTo(view.snp.trailing).offset(-32)
        }
    }
   
    private func setupAnimation() {
        animationView = .init(name: "widget")
        animationView!.contentMode = .scaleAspectFit
        animationView!.loopMode = .loop
        animationView!.animationSpeed = 0.9
        view.addSubview(animationView!)
        animationView?.snp.makeConstraints({ make in
            make.top.equalTo(instructionLabel.snp.bottom).offset(16)
            make.centerX.equalTo(view.snp.centerX)
            make.width.equalTo(view.snp.width)
            make.height.equalTo(view.snp.height).multipliedBy(0.4)
        })
        animationView!.play()
    }
}
