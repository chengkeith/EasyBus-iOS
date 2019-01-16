//
//  StarredEtaTableViewCell.swift
//  EasyBus
//
//  Created by KL on 15/10/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import UIKit

class StarredEtaTableViewCell: UITableViewCell {
    
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
    let colorTagView = UIView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        separatorInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        
        etaStackView.addArrangedSubview(etaLabel)
        etaStackView.addArrangedSubview(timeUnitLabel)
        
        contentView.add(stopNameLabel, routeNumberLabel, etaStackView, colorTagView)
        let views = ["stopNameLabel": stopNameLabel,
                     "routeNumberLabel": routeNumberLabel,
                     "etaStackView": etaStackView,
                     "colorTagView": colorTagView]
        NSLayoutConstraint.activateHighPriority(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[stopNameLabel]-8-|", options: [], metrics: nil, views: views))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "|-4-[colorTagView(4)]-4-[routeNumberLabel(80)]", options: [.alignAllCenterY], metrics: nil, views: views))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "[etaStackView(60)]-8-|", options: [], metrics: nil, views: views))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "[routeNumberLabel]-8-[stopNameLabel]-8-[etaStackView]", options: [.alignAllCenterY], metrics: nil, views: views))
        colorTagView.al_heightEqualToView(stopNameLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configEtaView(starredViewModel: StarredStopViewModel, isTarget: Bool) {
        if isTarget {
            stopNameLabel.attributedText = starredViewModel.stopEtaAttributedString
        }else {
            stopNameLabel.attributedText = starredViewModel.stopAttributedString
        }
    }
    
    func configEtaView(starredViewModel: CNStarredStopViewModel, isTarget: Bool) {
        if isTarget {
            stopNameLabel.attributedText = starredViewModel.stopEtaAttributedString
        }else {
            stopNameLabel.attributedText = starredViewModel.stopAttributedString
        }
    }
}


