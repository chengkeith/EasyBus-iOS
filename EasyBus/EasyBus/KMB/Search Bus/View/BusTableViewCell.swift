//
//  BusTableViewCell.swift
//  EasyBus
//
//  Created by KL on 13/10/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import UIKit

class BusTableViewCell: UITableViewCell {
    
    let routeNumberLabel: UILabel = {
        let label = UILabel()
        label.font = EasyBusFont.font(type: .regular, 20)
        return label
    }()
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        accessoryType = .disclosureIndicator
        
        contentView.add(routeNumberLabel, descriptionLabel)
        let views = ["routeNumberLabel": routeNumberLabel,
                     "descriptionLabel": descriptionLabel]
        NSLayoutConstraint.activateHighPriority(NSLayoutConstraint.constraints(withVisualFormat: "V:|-16-[descriptionLabel]-16-|", options: [], metrics: nil, views: views))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[routeNumberLabel(80)]-8-[descriptionLabel]-16-|", options: [.alignAllCenterY], metrics: nil, views: views))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

