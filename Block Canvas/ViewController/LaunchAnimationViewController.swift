//
//  LaunchAnimationViewController.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/10/3.
//

import UIKit
import SnapKit
import Kingfisher

class LaunchAnimationViewController: UIViewController {
    
    private let imageView: AnimatedImageView = {
        let imageView = AnimatedImageView()
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
        imageView.loadImage("https://lh3.googleusercontent.com/drive-viewer/AK7aPaD8e9Ix2J29NQ3Yyi6BZ_0NswIY8nkCMMHaJUaO6elq4owRtu_DhAH7idGtCZSiIkt7-VT4aO8oE4s1gQcHWqnBAdHb=s1600")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
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
