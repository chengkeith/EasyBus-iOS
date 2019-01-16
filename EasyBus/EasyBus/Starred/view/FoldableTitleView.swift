//
//  FoldableTitleView.swift
//  EasyBus
//
//  Created by KL on 5/11/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import UIKit
import Material

protocol FoldableTitleViewDelegate: class {
    func didTapSection(section: Int)
}

class FoldableTitleView: UIView {
    
    let titleLabel = UILabel()
    let arrowDownImageView = UIImageView()
    var section: Int?
    weak var delegate: FoldableTitleViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapView)))
        
        titleLabel.font = EasyBusFont.font(type: .demiBold, 16)
        titleLabel.textColor = .white
        
        arrowDownImageView.image = Icon.cm.arrowDownward
        arrowDownImageView.tintColor = .white
        arrowDownImageView.contentMode = .scaleAspectFit
        
        backgroundColor = .lightGray
        add(titleLabel, arrowDownImageView)
        
        let views = ["titleLabel": titleLabel,
                     "arrowDownImageView": arrowDownImageView]
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "|-16-[titleLabel(>=1)][arrowDownImageView]-26-|", options: [.alignAllTop, .alignAllBottom], metrics: nil, views: views))
        titleLabel.al_centerYToView()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func transformArrowToUpward() {
        arrowDownImageView.transform = CGAffineTransform.identity.rotated(by: CGFloat.pi)
    }
    
    @objc func didTapView() {
        guard let section = section else { return }
        
        delegate?.didTapSection(section: section)
    }
}
