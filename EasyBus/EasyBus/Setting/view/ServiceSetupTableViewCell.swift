//
//  ServiceSetupTableViewCell.swift
//  EasyBus
//
//  Created by KL on 20/10/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import Material
import UIKit

class ServiceSetupTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    let textField = InsetTextField()
    let confirmTestButton = ConfirmTestButton(frame: .zero)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        textField.autocapitalizationType = .none
        textField.delegate = self
        textField.font = EasyBusFont.font(type: .regular, 16)
        confirmTestButton.addTarget(self, action: #selector(didClickConfirmTestButton), for: .touchUpInside)
        resetConfirmButton()
        
        contentView.add(textField, confirmTestButton)
        let views = ["textField": textField,
                     "confirmTestButton": confirmTestButton]
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[textField]|", options: [], metrics: nil, views: views))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "|[textField][confirmTestButton(100)]|", options: [.alignAllTop, .alignAllBottom], metrics: nil, views: views))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func didClickConfirmTestButton() {
        if !confirmTestButton.isSelected, let newService = textField.text {
            APIManager.shared.testEtaService(url: newService) { (error, response) in
                if response?.responsecode != nil || response?.etas != nil {
                    UserSettingManager.shared.serviceUrl = newService
                    self.finishTesting(isSuccess: true)
                }else {
                    self.finishTesting(isSuccess: false)
                }
            }
            textField.isEnabled = false
            confirmTestButton.isSelected = true
        }
    }
    
    func finishTesting(isSuccess: Bool) {
        DispatchQueue.main.async {
            self.textField.isEnabled = true
            self.confirmTestButton.isSelected = false
            if isSuccess {
                self.confirmTestButton.setTitle("成功", for: .normal)
            }else {
                self.confirmTestButton.setTitle("失敗", for: .normal)
            }
        }
    }
    
    func resetConfirmButton() {
        confirmTestButton.isSelected = false
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("textFieldDidBeginEditing")
        confirmTestButton.setTitle("確定並測試", for: .normal)
    }
}

class CNBusServiceSetupTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    let textField = InsetTextField()
    let confirmTestButton = ConfirmTestButton(frame: .zero)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        textField.autocapitalizationType = .none
        textField.delegate = self
        textField.font = EasyBusFont.font(type: .regular, 16)
        confirmTestButton.addTarget(self, action: #selector(didClickConfirmTestButton), for: .touchUpInside)
        resetConfirmButton()
        
        contentView.add(textField, confirmTestButton)
        let views = ["textField": textField,
                     "confirmTestButton": confirmTestButton]
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[textField]|", options: [], metrics: nil, views: views))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "|[textField][confirmTestButton(100)]|", options: [.alignAllTop, .alignAllBottom], metrics: nil, views: views))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func didClickConfirmTestButton() {
        if !confirmTestButton.isSelected, let newService = textField.text {
            textField.isEnabled = false
            confirmTestButton.isSelected = true
            if newService == "http://172.217.24.206" {
                UserSettingManager.shared.cnServiceUrl = newService
                self.finishTesting(isSuccess: true)
            }else {
                APIManager.shared.testCNService(urlString: newService) { (_, buses) in
                    if buses != nil {
                        UserSettingManager.shared.cnServiceUrl = newService
                        self.finishTesting(isSuccess: true)
                    }else {
                        self.finishTesting(isSuccess: false)
                    }
                }
            }
        }
    }
    
    func finishTesting(isSuccess: Bool) {
        DispatchQueue.main.async {
            self.textField.isEnabled = true
            self.confirmTestButton.isSelected = false
            if isSuccess {
                self.confirmTestButton.setTitle("成功", for: .normal)
            }else {
                self.confirmTestButton.setTitle("失敗", for: .normal)
            }
        }
    }
    
    func resetConfirmButton() {
        confirmTestButton.isSelected = false
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("textFieldDidBeginEditing")
        confirmTestButton.setTitle("確定並測試", for: .normal)
    }
}

class ConfirmTestButton: RaisedButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel?.font = EasyBusFont.font(type: .regular, 14)
        setTitle("確定並測試", for: .normal)
        setTitle("測試中", for: .selected)
        setTitleColor(.white, for: UIControlState())
        backgroundColor = EasyBusColor.appColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? UIColor.darkGray : EasyBusColor.appColor
        }
    }
}

class InsetTextField: UITextField {
    
    let padding = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 16)
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
}
