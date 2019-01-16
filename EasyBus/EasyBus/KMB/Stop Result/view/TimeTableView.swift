//
//  TimeTableView.swift
//  EasyBus
//
//  Created by KL on 6/11/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import UIKit

class TimeTableTitleStackView: UIView {

    let leftLabel = InsetLabel()
    let rightLabel = InsetLabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configLabel(Labels: [leftLabel, rightLabel])
        
//        stackView.axis = .horizontal
//        stackView.distribution = .fillProportionally
//        stackView.addArrangedSubview(leftLabel)
//        stackView.addArrangedSubview(rightLabel)
        add(leftLabel, rightLabel)
        let views = ["leftLabel": leftLabel,
                     "rightLabel": rightLabel]
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "|[leftLabel][rightLabel]|", options: [.alignAllTop, .alignAllBottom], metrics: nil, views: views))
        rightLabel.widthAnchor.constraint(equalTo: leftLabel.widthAnchor, multiplier: 0.7).isActive = true
        leftLabel.al_fillSuperViewVertically()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configLabel(Labels: [UILabel]) {
        for label in Labels {
            label.lineBreakMode = .byCharWrapping
            label.numberOfLines = 0
            label.layoutEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
            label.translatesAutoresizingMaskIntoConstraints = false
            LabelAppearanceConfig(label: label)
        }
    }
    
    func LabelAppearanceConfig(label: UILabel) {
        label.textColor = .darkGray
        label.font = EasyBusFont.font(type: .demiBold, 15)
        label.backgroundColor = UIColor.rgb(r: 247, g: 247, b: 247)
    }
}

class InsetLabel: UILabel {
    
    var insets: UIEdgeInsets
    
    init(insets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)) {
        self.insets = insets
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
}

class TimeTableDetailStackView: TimeTableTitleStackView {
    
    override func LabelAppearanceConfig(label: UILabel) {
        label.font = EasyBusFont.font(type: .regular, 17)
        label.textColor = .lightGray
    }
}

class TimeTableTableViewCell: UITableViewCell {
    
    private let timeLabelView = TimeTableDetailStackView()
    var periodString: String? {
        didSet {
            if periodString == "" {
                timeLabelView.leftLabel.text = " "
            }else {
                timeLabelView.leftLabel.text = periodString
            }
            
        }
    }
    var frequencyString: String? {
        didSet {
            if frequencyString == "" {
                timeLabelView.rightLabel.text = " "
            }else {
                timeLabelView.rightLabel.text = frequencyString
            }
        }
    }
    var isCurrentPeriod: Bool = false {
        didSet {
            if isCurrentPeriod {
                setLabelFontAndColor(label: timeLabelView.leftLabel, color: EasyBusColor.appColor)
                setLabelFontAndColor(label: timeLabelView.rightLabel, color: EasyBusColor.appColor)
            }else {
                setLabelFontAndColor(label: timeLabelView.leftLabel, color: .lightGray)
                setLabelFontAndColor(label: timeLabelView.rightLabel, color: .lightGray)
            }
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        separatorInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        selectionStyle = .none
        
        contentView.add(timeLabelView)
        
        let views = ["timeLabelView": timeLabelView]
        NSLayoutConstraint.activateHighPriority(NSLayoutConstraint.constraints(withVisualFormat: "V:|-12-[timeLabelView]-12-|", options: [], metrics: nil, views: views))
        timeLabelView.al_fillSuperview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setLabelFontAndColor(label: UILabel, color: UIColor) {
        
        if let periodString = label.text, periodString.count > 13 {
            label.font = EasyBusFont.font(type: .regular, 14)
        }else {
            label.font = EasyBusFont.font(type: .demiBold, 16)
        }
        
        label.textColor = color
    }
}
