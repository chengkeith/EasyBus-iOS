//
//  PremissionTableViewCell.swift
//  EasyBus
//
//  Created by KL on 16/10/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import UIKit

protocol PremissionTableViewCellProtocol: class {
    func didTapSiwtch(tapSwitch: UISwitch, indexPath: IndexPath)
}

class PremissionTableViewCell: SettingBaseTableViewCell {
    
    weak var delegate: PremissionTableViewCellProtocol?
    let enableSwitch = UISwitch()
    var indexPath: IndexPath?
    let premissionTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = EasyBusFont.font(type: .regular, 16)
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.add(enableSwitch, premissionTitleLabel)
        let views = ["premissionTitleLabel": premissionTitleLabel,
                     "enableSwitch": enableSwitch]
        
        NSLayoutConstraint.activateHighPriority(NSLayoutConstraint.constraints(withVisualFormat: "|-16-[premissionTitleLabel]-8-[enableSwitch]-16-|", options: [.alignAllCenterY], metrics: nil, views: views))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|-16-[enableSwitch]-16-|", options: [], metrics: nil, views: views))
        
        enableSwitch.addTarget(self, action: #selector(didTapSiwtch(_ :)), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func didTapSiwtch(_ target: UISwitch) {
        guard let indexPath = indexPath else { return }
        delegate?.didTapSiwtch(tapSwitch: target, indexPath: indexPath)
    }
}
