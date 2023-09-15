//
//  BCTabBarController.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/9/14.
//

import UIKit

class BCTabBarController: UITabBarController {
    private let tabs: [Tab] = [.discover]
    
    private var orderObserver: NSKeyValueObservation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewControllers = tabs.map { $0.makeViewController() }

    }
}

// MARK: - Tabs
extension BCTabBarController {
    private enum Tab {
        case discover
        
        func makeViewController() -> UIViewController {
            let controller: UIViewController
            switch self {
                case .discover: controller = UIStoryboard.lobby.instantiateInitialViewController()!
            }
            controller.tabBarItem = makeTabBarItem()
            controller.tabBarItem.imageInsets = UIEdgeInsets(top: 6.0, left: 0.0, bottom: -6.0, right: 0.0)
            return controller
        }
        
        private func makeTabBarItem() -> UITabBarItem {
            return UITabBarItem(title: nil, image: nil, selectedImage: nil)
            // TODO: update images
        }
        
//        private var image: UIImage? {
//            switch self {
//                case .discover:
//                    return .asset(.Icons_36px_Home_Normal)
//            }
//        }
//
//        private var selectedImage: UIImage? {
//            switch self {
//                case .lobby:
//                    return .asset(.Icons_36px_Home_Selected)
//            }
//        }
    }
}