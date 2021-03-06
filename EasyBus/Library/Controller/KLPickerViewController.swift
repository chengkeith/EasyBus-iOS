//
//  KLPickerViewController.swift
//  iOS Practice
//
//  Created by KL on 6/9/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import UIKit

class KLPickerViewController: BottomCardViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var doneTitle: String? = nil
    var callbackImmediatelyWhenValueChange = false
    var didCancelCallback: (() -> ())?
    let navigationBar = UINavigationBar()
    var items: [String]
    
    private var pickerView: UIPickerView!
    private var selectedIndex: Int!
    private var didSelectAtIndexCallback: ((Int) -> ())?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(items: [String], selectedIndex: Int = 0, didSelectAtIndexCallback: @escaping (Int) -> ()) {
        self.items = items
        self.didSelectAtIndexCallback = didSelectAtIndexCallback
        self.selectedIndex = selectedIndex
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.backgroundColor = UIColor.white
        contentView.add(pickerView)
        pickerView.selectRow(selectedIndex, inComponent: 0, animated: false)
        
        contentView.add(navigationBar)
        
        let doneButtonItem: UIBarButtonItem
        if let doneTitle = doneTitle {
            doneButtonItem = UIBarButtonItem(title: doneTitle, style: .done, target: self, action: #selector(didDone))
        }
        else {
            doneButtonItem = UIBarButtonItem(title: "確定", style: .done, target: self, action: #selector(didDone))
        }
        navigationItem.rightBarButtonItem = doneButtonItem
        navigationBar.items = [navigationItem]
        
        let views: [String: Any] = ["pickerView": pickerView,
                                    "navigationBar": navigationBar]
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[navigationBar(44)][pickerView]|", options: [.alignAllLeft, .alignAllRight], metrics: nil, views: views))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "|[navigationBar]|", options: [], metrics: nil, views: views))
    }
    
    // MARK: - UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return items.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return items[row]
    }
    
    // MARK: - UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedIndex = row
        if callbackImmediatelyWhenValueChange, let didSelectAtIndexCallback = self.didSelectAtIndexCallback {
            didSelectAtIndexCallback(selectedIndex)
        }
    }
    
    // MARK: -
    
    @objc override func didTapDimView() {
        if callbackImmediatelyWhenValueChange {
            didDone()
        }else {
            dismiss(animated: true) {
                self.didCancelCallback?()
            }
        }
    }
}

private extension KLPickerViewController {
    @objc func didDone() {
        dismiss(animated: true) {
            self.didSelectAtIndexCallback?(self.selectedIndex)
        }
    }
}
