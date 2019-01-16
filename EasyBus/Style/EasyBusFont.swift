//
//  EasyBusFont.swift
//  EasyBus
//
//  Created by KL on 16/10/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import UIKit

class EasyBusFont {
    
    enum FontType: String {
        case regular = "AvenirNext-Regular"
        case semiBold = "AvenirNext-Medium"
        case demiBold = "AvenirNext-DemiBold"
        case bold = "AvenirNext-Bold"
        case heavy = "Avenir-Heavy"
        case daughter = "ArchitectsDaughter"
    }
    
    static func font(type font: FontType, _ size: CGFloat) -> UIFont {
        let targetFont: UIFont
        
        if let customFont = UIFont(name: font.rawValue, size: size) {
            targetFont = customFont
        }else {
            targetFont = UIFont.systemFont(ofSize: size)
        }
        
        var fontMetrics: UIFontMetrics
        if size < 14 {
            fontMetrics = UIFontMetrics(forTextStyle: .footnote)
        }else if size < 20 {
            fontMetrics = UIFontMetrics(forTextStyle: .title3)
        }else {
            fontMetrics = UIFontMetrics(forTextStyle: .title1)
        }
        
        return fontMetrics.scaledFont(for: targetFont)
    }
}
