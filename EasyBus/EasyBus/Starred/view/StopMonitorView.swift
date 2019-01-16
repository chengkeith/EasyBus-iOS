//
//  StopMonitorView.swift
//  EasyBus
//
//  Created by KL on 24/10/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import UIKit

class StopMonitorView: UIView {
    
    weak var starredStopViewModel: StarredStopViewModel?
    let remainingTimeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "23:52"
        label.minimumScaleFactor = 0.1
        label.textColor = EasyBusColor.appColor
        label.font = EasyBusFont.font(type: .regular, 200)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        add(remainingTimeLabel)
        remainingTimeLabel.al_rightToView(self, distance: -8, priority: .defaultHigh)
        remainingTimeLabel.al_bottomToView(self, distance: -8, alignToSafeArea: false, priority: .defaultHigh)
        remainingTimeLabel.al_leftToView(self, distance: 8, priority: .defaultHigh)
        remainingTimeLabel.al_topToView(self, distance: 8, alignToSafeArea: false, priority: .defaultHigh)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
