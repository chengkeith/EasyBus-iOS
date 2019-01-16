//
//  EtaAttribute.swift
//  EasyBus
//
//  Created by KL on 16/10/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import UIKit

class EtaAttribute {
    static let smallRegular = [NSAttributedStringKey.font: EasyBusFont.font(type: .regular, 10)]
    static let regular = [NSAttributedStringKey.font: EasyBusFont.font(type: .regular, 14),
                          NSAttributedStringKey.foregroundColor: UIColor.darkGray]
    static let regularSemibold = [NSAttributedStringKey.font:  EasyBusFont.font(type: .semiBold, 14),
                                  NSAttributedStringKey.foregroundColor: UIColor.blue]
    static let redRegularSemibold = [NSAttributedStringKey.font:  EasyBusFont.font(type: .semiBold, 14),
                                     NSAttributedStringKey.foregroundColor: UIColor.red]
    static let darkGraySmallRegularSemibold = [NSAttributedStringKey.font: EasyBusFont.font(type: .regular, 14),
                                               NSAttributedStringKey.foregroundColor: UIColor.darkGray]
    static let darkGrayLargeRegularSemibold = [NSAttributedStringKey.font: EasyBusFont.font(type: .regular, 18),
                                               NSAttributedStringKey.foregroundColor: UIColor.darkGray]
    static let lightGarySmallRegular = [NSAttributedStringKey.font: EasyBusFont.font(type: .regular, 12),
                                        NSAttributedStringKey.foregroundColor: UIColor.lightGray]
}

class SettingAttribute {
    static let regular = [NSAttributedStringKey.font: EasyBusFont.font(type: .demiBold, 14),
                          NSAttributedStringKey.foregroundColor: UIColor.darkGray]
    static let regularAppColor = [NSAttributedStringKey.font: EasyBusFont.font(type: .demiBold, 16),
                          NSAttributedStringKey.foregroundColor: EasyBusColor.appColor]
    static let sRegularAppColor = [NSAttributedStringKey.font: EasyBusFont.font(type: .demiBold, 14),
                                  NSAttributedStringKey.foregroundColor: EasyBusColor.appColor]
    static let keyRegular = [NSAttributedStringKey.font: EasyBusFont.font(type: .regular, 18),
                          NSAttributedStringKey.foregroundColor: UIColor.lightGray]
    static let body = [NSAttributedStringKey.font: EasyBusFont.font(type: .regular, 14),
                          NSAttributedStringKey.foregroundColor: UIColor.darkGray]
    static let smallBody = [NSAttributedStringKey.font: EasyBusFont.font(type: .regular, 12),
                       NSAttributedStringKey.foregroundColor: UIColor.darkGray]
    static let bodyAppColor = [NSAttributedStringKey.font: EasyBusFont.font(type: .regular, 16),
                       NSAttributedStringKey.foregroundColor: EasyBusColor.appColor]
}
