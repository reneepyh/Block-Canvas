//
//  UIColor+Extension.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/9/24.
//

import UIKit

extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexValue = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()

        if hexValue.hasPrefix("#") {
            hexValue.remove(at: hexValue.startIndex)
        }

        var rgbValue: UInt64 = 0
        Scanner(string: hexValue).scanHexInt64(&rgbValue)

        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    static let primary = UIColor(hex: "332627", alpha: 1)
    
    static let secondary = UIColor(hex: "EEE9D4", alpha: 1)
    
    static let secondaryBlur = UIColor(hex: "EEE9D4", alpha: 0.5)
    
    static let tertiary = UIColor(hex: "BB9861", alpha: 1)
}
