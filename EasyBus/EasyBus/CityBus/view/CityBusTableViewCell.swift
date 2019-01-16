//
//  CityBusTableViewCell.swift
//  EasyBus
//
//  Created by KL on 4/11/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import UIKit

class ServiceTableViewCell: UITableViewCell {
    
    let tagColorBackground = UIView()
    let titleLabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        titleLabel.numberOfLines = 0
        titleLabel.font = EasyBusFont.font(type: .regular, 14)
        accessoryType = .disclosureIndicator
        
        contentView.add(tagColorBackground, titleLabel)
        
        let views = ["tagColorBackground": tagColorBackground,
                     "titleLabel": titleLabel]
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|-16-[titleLabel]-16-|", options: [], metrics: nil, views: views))
        NSLayoutConstraint.activateHighPriority(NSLayoutConstraint.constraints(withVisualFormat: "|-16-[tagColorBackground(8)]-8-[titleLabel]-16-|", options: [.alignAllTop, .alignAllBottom], metrics: nil, views: views))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
