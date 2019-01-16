//
//  EtaTableViewCell.swift
//  iOS Practice
//
//  Created by KL on 17/8/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import UIKit

protocol EtaTableViewCellDelegate: class {
    func starredButtonOnClicked(for indexPath: IndexPath)
}

class EtaTableViewCell: UITableViewCell {
    
    var indexPath: IndexPath?
    weak var delegate: EtaTableViewCellDelegate?
    
    let stopNameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .darkGray
        label.font = EasyBusFont.font(type: .regular, 18)
        return label
    }()
    let etaLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = EasyBusFont.font(type: .regular, 24)
        label.textColor = .darkGray
        return label
    }()
    let starButton = StarButton()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        starButton.accessibilityLabel = "收藏此站"
        starButton.addTarget(self, action: #selector(didTapSave), for: .touchUpInside)
        
        contentView.add(stopNameLabel, etaLabel, starButton)
        let views = ["stopNameLabel": stopNameLabel,
                     "etaLabel": etaLabel,
                     "starButton": starButton]
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|-16-[stopNameLabel]-8-[etaLabel]-16-|", options: [.alignAllLeft, .alignAllRight], metrics: nil, views: views))
        NSLayoutConstraint.activateHighPriority(NSLayoutConstraint.constraints(withVisualFormat: "|-16-[stopNameLabel]-8-[starButton(80)]|", options: [], metrics: nil, views: views))
        
        starButton.al_fillSuperViewVertically()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configEtaView(stopViewModel: StopViewModel, isTarget: Bool) {
        if let etas = stopViewModel.etas, isTarget {
            let etaViewModel = EtaViewModel(etas: etas)
            etaLabel.attributedText = etaViewModel.etasAttributedString
        }else if isTarget {
            etaLabel.attributedText = stopViewModel.fetchingEtaStatusAttributedString
        }else {
            etaLabel.attributedText = nil
        }
        layoutIfNeeded()
    }
    
    func configEtaView(stopViewModel: CNBusStopViewModel, isTarget: Bool) {
        if let etas = stopViewModel.etas, isTarget {
            let etaViewModel = CNBusEtaViewModel(etas: etas)
            etaLabel.attributedText = etaViewModel.etasAttributedString
        }else if isTarget {
            etaLabel.attributedText = stopViewModel.fetchingEtaStatusAttributedString
        }else {
            etaLabel.attributedText = nil
        }
        layoutIfNeeded()
    }
    
    @objc func didTapSave() {
        guard let indexPath = indexPath else {
            return
        }
        starButton.pulse()
        delegate?.starredButtonOnClicked(for: indexPath)
    }
}
