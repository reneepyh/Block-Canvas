//
//  BCTabBarController.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/9/14.
//

import UIKit

class BCTabBarController: UITabBarController {
    private let tabs: [Tab] = [.discover, .portfolio, .crypto, .settings]
    
    private var orderObserver: NSKeyValueObservation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewControllers = tabs.map { $0.makeViewController() }

    }
}

// MARK: - Tabs
extension BCTabBarController {
    private enum Tab {
        case discover
        case portfolio
        case crypto
        case settings
        
        func makeViewController() -> UIViewController {
            let controller: UIViewController
            switch self {
                case .discover: controller = UIStoryboard.discover.instantiateInitialViewController()!
                case .portfolio: controller = UIStoryboard.portfolio.instantiateInitialViewController()!
                case .crypto: controller = UIStoryboard.crypto.instantiateInitialViewController()!
                case .settings: controller = UIStoryboard.settings.instantiateInitialViewController()!
            }
            controller.tabBarItem = makeTabBarItem()
            controller.tabBarItem.imageInsets = UIEdgeInsets(top: 6.0, left: 0.0, bottom: -6.0, right: 0.0)
            return controller
        }
        
        private func makeTabBarItem() -> UITabBarItem {
            return UITabBarItem(title: nil, image: image, selectedImage: selectedImage)
        }
        
        private var image: UIImage? {
            switch self {
                case .discover:
                    return UIImage(named: "discover")
                case .portfolio:
                    return UIImage(named: "portfolio")
                case .crypto:
                    return UIImage(named: "crypto")
                case .settings:
                    return UIImage(named: "settings")
            }
        }

        private var selectedImage: UIImage? {
            switch self {
                case .discover:
                    return UIImage(named: "discover_selected")
                case .portfolio:
                    return UIImage(named: "portfolio_selected")
                case .crypto:
                    return UIImage(named: "crypto_selected")
                case .settings:
                    return UIImage(named: "settings_selected")
            }
        }
    }
}
