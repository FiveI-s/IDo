//
//  Color.swift
//  IDo
//
//  Created by 김도현 on 2023/10/11.
//

import Foundation
import UIKit
import SnapKit

enum Color: String, CaseIterable {
    //core color
    case main = "Main"
    case sub = "Sub"
    case negative = "Negative"
    case positive = "Positive"
    case black = "Black"
    case white = "White"

    //Background Colors
    case backgroundPrimary = "Background"
    case backgroundSecondary = "BackgroundSecondary"
    case backgroundTertiary = "BackgroundTertiary"

    //Content Colors
    case contentPrimary = "ContentPrimay"
    case contentPrimayPress = "ContentPrimary-Press"
    case contentBackground = "ContentBackground"
    
    //Border Colors
    case borderOpaque = "BorderOpaque"
    case borderSelected = "BorderSelected"
    
    //Text Colors
    case textStrong = "TextStrong"
    case text1 = "Text1"
    case text2 = "Text2"
    case textReadOnly = "TextReadonly"
    case placeholder = "Placeholder"
}

extension UIColor {
    convenience init(color: Color) {
        self.init(named: color.rawValue)!
    }
}

