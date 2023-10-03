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
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
                tabBarController?.tabBar.isHidden = true
                
                startImageAnimation()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.transitionToMainVC()
                }
    }

    private func setupUI() {
        view.backgroundColor = .primary
        view.addSubview(imageView)
        
        guard let data = NSDataAsset(name: "launch")?.data else { return }
        let cfData = data as CFData
        CGAnimateImageDataWithBlock(cfData, nil) { (_, cgImage, _) in
            self.imageView.image = UIImage(cgImage: cgImage)
        }
        
        imageView.snp.makeConstraints { make in
            make.centerX.equalTo(view.snp.centerX)
            make.centerY.equalTo(view.snp.centerY)
            make.width.equalTo(view.snp.width).multipliedBy(0.9)
        }
    }
    
    private func startImageAnimation() {
           guard let data = NSDataAsset(name: "launch")?.data else { return }
           let cfData = data as CFData
           CGAnimateImageDataWithBlock(cfData, nil) { (_, cgImage, _) in
               self.imageView.image = UIImage(cgImage: cgImage)
           }
       }
       
       private func transitionToMainVC() {
//           guard
//               let mainVC = UIStoryboard.main.instantiateViewController(
//                   withIdentifier: String(describing: BCTabBarController.self)
//               ) as? BCTabBarController
//           else {
//               return
//           }
//           mainVC.modalPresentationStyle = .overFullScreen
//           self.present(mainVC, animated: false) {
               self.dismiss(animated: false)
//           }
       }
}
