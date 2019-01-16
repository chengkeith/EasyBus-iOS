//
//  RemindView.swift
//  EasyBus
//
//  Created by KL on 21/10/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import UIKit

class RemindView: UIView {
    
    let remindTextLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = EasyBusColor.appColor
        label.textAlignment = .center
        label.font = EasyBusFont.font(type: .regular, 18)
        return label
    }()
    let remindImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "remind")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupAutoLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupAutoLayout() {
        add(remindTextLabel, remindImage)
        
        let views = ["remindTextLabel": remindTextLabel,
                     "remindImage": remindImage]
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "|-16-[remindTextLabel][remindImage(160)]|", options: [.alignAllCenterY], metrics: nil, views: views))
        remindImage.al_centerYToView()
        remindImage.al_fillSuperViewVertically()
    }
}
