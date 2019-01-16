//
//  AboutUserViewModel.swift
//  EasyBus
//
//  Created by KL on 20/10/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import UIKit

class AboutUserViewModel {
    
    static var serviceHelperAttributedString: NSAttributedString {
        let attributedSentence = NSMutableAttributedString(string: "請在下方輸入已授權的團體／個人所提供的網址\n例子: http://159.89.196.81:9999/example\n必須加上http://或https://", attributes: SettingAttribute.smallBody)
        return attributedSentence
    }
    static var mustReadAttributedString: NSAttributedString {
        let attributedSentence = NSMutableAttributedString(string: "EasyBus", attributes: SettingAttribute.bodyAppColor)
        attributedSentence.append(NSMutableAttributedString(string: " 只提供", attributes: SettingAttribute.body))
        attributedSentence.append(NSMutableAttributedString(string: "搜尋巴士到站時間的介面", attributes: SettingAttribute.bodyAppColor))
        attributedSentence.append(NSMutableAttributedString(string: "，我們並", attributes: SettingAttribute.body))
        attributedSentence.append(NSMutableAttributedString(string: "不提供到站時間服務", attributes: SettingAttribute.bodyAppColor))
        attributedSentence.append(NSMutableAttributedString(string: "。用戶必須從已授權的團體／個人獲取到站時間的資料。如用戶使用非法途徑取得這些服務，與EasyBus無關。\n\n", attributes: SettingAttribute.body))
        attributedSentence.append(NSMutableAttributedString(string: "用戶: ", attributes: SettingAttribute.bodyAppColor))
        attributedSentence.append(NSMutableAttributedString(string: "要使用到站時間服務只需要輸入", attributes: SettingAttribute.body))
        attributedSentence.append(NSMutableAttributedString(string: "已授權的團體／個人所提供的網址", attributes: SettingAttribute.bodyAppColor))
        attributedSentence.append(NSMutableAttributedString(string: "便可即時使用此功能。\n\n", attributes: SettingAttribute.body))
        attributedSentence.append(NSMutableAttributedString(string: "開發者: ", attributes: SettingAttribute.bodyAppColor))
        attributedSentence.append(NSMutableAttributedString(string: "請跟從下方的開發者教學，開發一個兼容EasyBus的到站時間服務。", attributes: SettingAttribute.body))
        
        return attributedSentence
    }
}
