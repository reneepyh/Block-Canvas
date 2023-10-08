//
//  LaunchAnimationViewController.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/10/3.
//

import UIKit
import SnapKit

class LaunchAnimationViewController: UIViewController {
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupAnimation()
    }
    
    private func setupUI() {
        view.backgroundColor = .primary
        view.addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.centerX.equalTo(view.snp.centerX)
            make.centerY.equalTo(view.snp.centerY)
            make.width.equalTo(view.snp.width).multipliedBy(0.9)
            make.height.equalTo(imageView.snp.width)
        }
    }
    
    private func setupAnimation() {
        imageView.loadGif(asset: "launch")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            guard let mainVC = UIStoryboard.main.instantiateViewController(
                withIdentifier: String(describing: BCTabBarController.self)
            ) as? BCTabBarController
            else {
                return
            }
            UIApplication.shared.windows.first?.rootViewController = mainVC
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        }
    }
}
