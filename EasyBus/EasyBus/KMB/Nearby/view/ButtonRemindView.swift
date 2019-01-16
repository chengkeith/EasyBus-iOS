//
//  ButtonRemindView.swift
//  EasyBus
//
//  Created by KL on 21/10/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import UIKit
import Material

protocol ButtonRemindViewDelegate: class {
    func didClickedRemindViewButton(_ sender: UIButton)
}

class ButtonRemindView: RemindView {
    
    weak var delegate: ButtonRemindViewDelegate?
    let remindButton = RaisedButton()
    
    override func setupAutoLayout() {
        remindButton.backgroundColor = EasyBusColor.appColor
        remindButton.setTitleColor(.white, for: UIControlState())
        remindButton.pulseColor = .darkGray
        remindButton.layer.cornerRadius = 4
        remindButton.clipsToBounds = true
        remindButton.addTarget(self, action: #selector(didClickedRemindButton(_ :)), for: .touchUpInside)
        
        add(remindTextLabel, remindImage, remindButton)
        
        let views = ["remindTextLabel": remindTextLabel,
                     "remindImage": remindImage,
                     "remindButton": remindButton]
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "|-16-[remindTextLabel][remindImage(160)]|", options: [.alignAllCenterY], metrics: nil, views: views))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "|-24-[remindButton]-24-|", options: [], metrics: nil, views: views))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[remindImage]-36-[remindButton]-64-|", options: [], metrics: nil, views: views))
    }
    
    @objc func didClickedRemindButton(_ sender: UIButton) {
        delegate?.didClickedRemindViewButton(sender)
    }
}
