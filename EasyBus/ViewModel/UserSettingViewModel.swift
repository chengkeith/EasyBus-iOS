//
//  UserSettingViewModel.swift
//  EasyBus
//
//  Created by KL on 18/10/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import UIKit

class UserSettingViewModel {
    
    static func attributedValueSetting(prefix: String? = nil, key: String? = nil, postfix: String? = nil) -> NSAttributedString {
        let attributedSentence = NSMutableAttributedString(string: "", attributes: SettingAttribute.regular)
        
        if let prefix = prefix {
            attributedSentence.append(NSMutableAttributedString(string: prefix, attributes: SettingAttribute.regular))
        }
        
        if let key = key {
            attributedSentence.append(NSMutableAttributedString(string: key, attributes: SettingAttribute.keyRegular))
        }
        
        if let postfix = postfix {
            attributedSentence.append(NSMutableAttributedString(string: postfix, attributes: SettingAttribute.regular))
        }
        
        return attributedSentence
    }
    
    static var aboutUsAttributedString: NSAttributedString {
        let attributedSentence = NSMutableAttributedString(string: "關於EasyBus ", attributes: SettingAttribute.regular)
        attributedSentence.append(NSMutableAttributedString(string: "【使用前必看！】", attributes: SettingAttribute.regularAppColor))
        return attributedSentence
    }
    
    static var donateAttributedString: NSAttributedString {
        let attributedSentence = NSMutableAttributedString(string: "支持開發者", attributes: SettingAttribute.sRegularAppColor)
        return attributedSentence
    }
    
    static var updateDataAttributedString: NSAttributedString {
        let attributedSentence = NSMutableAttributedString(string: "更新車站資料 － ", attributes: SettingAttribute.regular)
        attributedSentence.append(NSMutableAttributedString(string: "\(KMBDataManager.shared.version)", attributes: SettingAttribute.body))
        return attributedSentence
    }
    
    static func attributedBody(body: String) -> NSAttributedString {
        return NSMutableAttributedString(string: body, attributes: SettingAttribute.body)
    }
}
