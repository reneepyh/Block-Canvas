//
//  UIStoryboard+Extension.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/9/14.
//

import UIKit

extension UIStoryboard {
    static var main: UIStoryboard { return bcStoryboard(name: "Main") }
    static var lobby: UIStoryboard { return bcStoryboard(name: "Discover") }
 
    private static func bcStoryboard(name: String) -> UIStoryboard {
        return UIStoryboard(name: name, bundle: nil)
    }
}
