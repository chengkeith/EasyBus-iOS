//
//  SettingBaseTableViewCell.swift
//  EasyBus
//
//  Created by KL on 17/10/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import UIKit

class SettingBaseTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        imageView?.tintColor = EasyBusColor.appColor
        textLabel?.numberOfLines = 0
        textLabel?.font = EasyBusFont.font(type: .regular, 16)
        separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
