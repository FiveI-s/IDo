//
//  File.swift
//  IDo
//
//  Created by 김도현 on 2023/10/11.
//

import UIKit

extension UIFont {
    enum Body: CGFloat {
        case large = 18
        case medium = 16
        case small = 14
        case xSmall = 12
    }
    
    enum Heading: CGFloat {
        case xxLarge = 40
        case xLarge = 36
        case large = 32
        case xMedium = 28
        case small = 24
        case xSmall = 20
    }
    
    enum FontName: String {
        case bold = "SpoqaHanSansNeo-Bold"
        case medium = "SpoqaHanSansNeo-Medium"
        case regular = "SpoqaHanSansNeo-Regular"
        case light = "SpoqaHanSansNeo-Light"
        case thin = "SpoqaHanSansNeo-Thin"
    }
    
    static func bodyFont(_ label: Body, weight: Weight) -> UIFont {
        return systemFont(ofSize: label.rawValue, weight: weight)
    }
    
    static func headFont(_ head: Heading, weight: Weight) -> UIFont {
        return systemFont(ofSize: head.rawValue, weight: weight)
    }
    
//    static func customFont(_ name: FontName, size: CGFloat) -> UIFont {
//        return UIFont(name: name.rawValue, size: size) ?? UIFont.systemFont(ofSize: size)
//    }
//    
//    static func bodyFont(_ label: Body, weight: FontName) -> UIFont {
//        return customFont(weight, size: label.rawValue)
//    }
//    
//    static func headFont(_ head: Heading, weight: FontName) -> UIFont {
//        return customFont(weight, size: head.rawValue)
//    }
}
