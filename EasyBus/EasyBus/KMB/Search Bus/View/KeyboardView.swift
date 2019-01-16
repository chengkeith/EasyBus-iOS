//
//  KeyBoardView.swift
//  EasyBus
//
//  Created by KL on 18/10/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import UIKit

protocol KeyBoardViewDelegate: class {
    func didClickInputButton(key: String)
    func didClickDeleteButton()
    func didClickCancelButton()
}

class KeyboardView: UIView {
    
    enum SpecialKey: String {
        case number = "數字"
        case letter = "字母"
        case cancel = "取消"
        case del = "移除"
        
        var tag: Int {
            switch self {
            case .number:
                return 0
            case .del:
                return 100
            case .cancel:
                return 10
            case .letter:
                return 1000
            }
        }
    }
    
    weak var delegate: KeyBoardViewDelegate?
    let letterStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        return stackView
    }()
    let numPadStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        return stackView
    }()
    var mainNumPadButtons: [String: NumPadButton] = [:]
    var charNumPadButtons: [NumPadButton] = []
    let keyRows = [["1", "2", "3"], ["4", "5", "6"], ["7", "8", "9"], [SpecialKey.cancel.rawValue, "0", SpecialKey.del.rawValue]]
    let order = [2, 5, 8, 11, 1, 4, 7, 10, 0, 3, 6, 9]
    
    init() {
        super.init(frame: .zero)
        
        // init mainKeyboard
        for keys in keyRows {
            let stack = generateRowStackView(isRight: true)
            for key in keys {
                let button = generateButton(name: key)
                mainNumPadButtons[key] = button
                stack.addArrangedSubview(button)
            }
            numPadStack.addArrangedSubview(stack)
        }
        
        // charkeyBoard (letterStack)
        for _ in 0...3 {
            let stack = generateRowStackView(isRight: false)
            for _ in 0...2 {
                let button = generateButton(name: "A")
                charNumPadButtons.append(button)
                stack.addArrangedSubview(button)
            }
            letterStack.addArrangedSubview(stack)
        }
        
        backgroundColor = .lightGray
        
        add(numPadStack, letterStack)
        let views = ["numPadStack": numPadStack,
                     "letterStack": letterStack]
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "|[letterStack][numPadStack]|", options: [.alignAllTop, .alignAllBottom], metrics: nil, views: views))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[numPadStack]|", options: [], metrics: nil, views: views))
        numPadStack.al_widthEqualToView(letterStack)
        
        initKeyBoard()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initKeyBoard() {
        guard 0 < KMBDataManager.shared.keyboards.count, order.count == charNumPadButtons.count else {
            return
        }
        let letterKeys = KMBDataManager.shared.keyboards[0].filter { (s) -> Bool in
            return s >= "A"
        }
        
        resetLetterKeyboard(letterKeys: letterKeys)
    }
    
    func resetLetterKeyboard(letterKeys: [String]) {
        guard order.count == charNumPadButtons.count else {
            fatalError("please set order = charNumPadButtons")
        }
        var i = 0
        var j = 0
        while (i < order.count) {
            if j < letterKeys.count {
                charNumPadButtons[order[i]].setTitle(letterKeys[j], for: UIControlState())
            }else {
                charNumPadButtons[order[i]].setTitle(nil, for: UIControlState())
            }
            i += 1
            j += 1
        }
    }
    
    func generateButton(name: String?) -> NumPadButton {
        let button = NumPadButton()
        button.addTarget(self, action: #selector(didClickKeyboard(_:)), for: .touchUpInside)
        
        if name != nil {
            switch name {
            case SpecialKey.del.rawValue:
                button.accessibilityLabel = "刪除"
                button.tag = SpecialKey.del.tag
                button.setImage(UIImage(named: "ic_edit_back"), for: UIControlState())
            case SpecialKey.cancel.rawValue:
                button.tag = SpecialKey.cancel.tag
                button.setTitleColor(.red, for: UIControlState.normal)
                button.setTitleColor(.white, for: UIControlState.highlighted)
                button.setTitle(name, for: UIControlState())
            default:
                button.tag = SpecialKey.number.tag
                button.setTitle(name, for: UIControlState())
            }
        }else {
            button.tag = SpecialKey.letter.tag
            button.setTitle("A", for: UIControlState())
        }
        return button
    }
    
    func generateRowStackView(isRight: Bool) -> UIStackView {
        let stackView = UIStackView()
        if isRight {
            stackView.layoutMargins = UIEdgeInsetsMake(4, 8, 4, 16)
        }else {
            stackView.layoutMargins = UIEdgeInsetsMake(4, 16, 4, 8)
        }
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        return stackView
    }
    
    @objc func didClickKeyboard(_ sender: NumPadButton) {
        switch sender.tag {
        case SpecialKey.cancel.tag:
            delegate?.didClickCancelButton()
        case SpecialKey.del.tag:
            delegate?.didClickDeleteButton()
        default:
            if let title = sender.currentTitle {
                delegate?.didClickInputButton(key: title)
            }
        }
    }
}

class NumPadButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel?.font = EasyBusFont.font(type: .demiBold, 18)
        setTitleColor(.darkGray, for: UIControlState.normal)
        setTitleColor(.white, for: UIControlState.highlighted)
        backgroundColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? UIColor.darkGray : UIColor.white
        }
    }
}
