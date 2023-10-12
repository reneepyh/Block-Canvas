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
    
//    static func show(type: HUDType) {
//        switch type {
//            case .success(let text):
//                showSuccess(text: text)
//            case .failure(let text):
//                showFailure(text: text)
//        }
//    }
    
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
    
    static func show(text: String = "Loading") {
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
        shared.hud.indicatorView = JGProgressHUDImageIndicatorView(image: loadingGif)
        shared.hud.textLabel.text = text
        shared.hud.textLabel.textColor = .secondaryBlur
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
