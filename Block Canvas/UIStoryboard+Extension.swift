//
//  UIStoryboard+Extension.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/9/14.
//

import UIKit

extension UIStoryboard {
    static var main: UIStoryboard { return bcStoryboard(name: "Main") }
    static var discover: UIStoryboard { return bcStoryboard(name: "Discover") }
    static var portfolio: UIStoryboard { return bcStoryboard(name: "Portfolio") }
 
    private static func bcStoryboard(name: String) -> UIStoryboard {
        return UIStoryboard(name: name, bundle: nil)
    }
}
