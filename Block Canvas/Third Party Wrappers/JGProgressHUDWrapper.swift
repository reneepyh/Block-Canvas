//
//  JGProgressHUDWrapper.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/9/23.
//

import JGProgressHUD

enum HUDType {
    case success(String)
    case failure(String)
}

class BCProgressHUD {
    
    static let shared = BCProgressHUD()
    
    private init() {}
    
    let hud = JGProgressHUD(style: .dark)
    
    var view: UIView? {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let delegate = windowScene.delegate as? SceneDelegate {
            return delegate.window?.rootViewController?.view
        }
        return nil
    }
    
    static func showSuccess(text: String = "Success", view: UIView) {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                showSuccess(text: text, view: view)
            }
            return
        }
        shared.hud.textLabel.text = text
        shared.hud.textLabel.textColor = .secondaryBlur
        shared.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
        shared.hud.show(in: view)
        shared.hud.dismiss(afterDelay: 1)
    }
    
    static func showFailure(text: String = "Failure") {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                showFailure(text: text)
            }
            return
        }
        shared.hud.textLabel.text = text
        shared.hud.textLabel.textColor = .secondaryBlur
        shared.hud.indicatorView = JGProgressHUDErrorIndicatorView()
        if let view = shared.view {
            shared.hud.show(in: view)
            shared.hud.dismiss(afterDelay: 2)
        }
    }
    
    static func show(text: String = "") {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                show(text: text)
            }
            return
        }
        
        guard let loadingGif = UIImage.gif(asset: "loading") else {
            print("Cannot find loading gif.")
            return
        }
        
        let gifIndicator = CustomGIFIndicatorView(gifImage: loadingGif)
        
        shared.hud.indicatorView = gifIndicator
        shared.hud.textLabel.text = text
        shared.hud.textLabel.textColor = .secondaryBlur
        
        if shared.hud.textLabel.text == "" {
            shared.hud.contentInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        } else {
            shared.hud.contentInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        }
        
        if let view = shared.view {
            shared.hud.show(in: view)
        }
    }
    
    static func dismiss() {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                dismiss()
            }
            return
        }
        shared.hud.dismiss()
    }
}

class CustomGIFIndicatorView: JGProgressHUDImageIndicatorView {
    private var gifImageView: UIImageView!
    
    init(gifImage: UIImage?) {
        super.init(image: UIImage())
        self.frame = CGRect(x: 0, y: 0, width: 70, height: 70)
        gifImageView = UIImageView()
        gifImageView.frame = self.bounds
        gifImageView.contentMode = .scaleAspectFit
        gifImageView.clipsToBounds = true
        gifImageView.image = gifImage
        addSubview(gifImageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
