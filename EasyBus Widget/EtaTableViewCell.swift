//
//  EtaTableViewCell.swift
//  EasyBus Widget
//
//  Created by KL on 8/11/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import UIKit

class EtaTableViewCell: UITableViewCell {
    
    let routeNumberLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = EasyBusFont.font(type: .semiBold, 24)
        return label
    }()
    let stopNameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .darkGray
        label.font = EasyBusFont.font(type: .regular, 18)
        return label
    }()
    let etaLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = EasyBusFont.font(type: .regular, 20)
        label.textAlignment = .center
        label.textColor = .blue
        return label
    }()
    let timeUnitLabel: UILabel = {
        let label = UILabel()
        label.text = "分鐘"
        label.font = EasyBusFont.font(type: .regular, 14)
        label.textAlignment = .center
        label.textColor = .darkGray
        return label
    }()
    let etaStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        separatorInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        
        etaStackView.addArrangedSubview(etaLabel)
        etaStackView.addArrangedSubview(timeUnitLabel)
        
        contentView.add(stopNameLabel, routeNumberLabel, etaStackView)
        let views = ["stopNameLabel": stopNameLabel,
                     "routeNumberLabel": routeNumberLabel,
                     "etaStackView": etaStackView]
        NSLayoutConstraint.activateHighPriority(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[etaStackView]-8-|", options: [], metrics: nil, views: views))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "|-8-[routeNumberLabel(80)]", options: [.alignAllCenterY], metrics: nil, views: views))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "[etaStackView(60)]-8-|", options: [], metrics: nil, views: views))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "[routeNumberLabel]-8-[stopNameLabel]-8-[etaStackView]", options: [.alignAllCenterY], metrics: nil, views: views))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
