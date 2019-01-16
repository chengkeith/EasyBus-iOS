//
//  KLBottomCardTableViewController.swift
//  EasyBus
//
//  Created by KL on 6/11/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import UIKit

class KLBottomCardTableViewController: BottomCardViewController {
    
    var navTitle: String? = nil
    var doneTitle: String? = nil
    let navigationBar = UINavigationBar()
    let tableView: UITableView
    
    init(style: UITableViewStyle) {
        tableView = UITableView(frame: .zero, style: style)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupNavigationBar()
        
        contentView.add(tableView, navigationBar)
        setupAutoLayout()
    }
    
    func setupAutoLayout() {
        let views = ["tableView": tableView,
                     "navigationBar": navigationBar]
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[navigationBar(40)][tableView(100)]|", options: [.alignAllLeft, .alignAllRight], metrics: nil, views: views))
        tableView.al_fillSuperViewHorizontally()
    }
    
    func customConfig(navTitle: String? = nil, doneTitle: String? = nil) {
        self.navTitle = navTitle
        self.doneTitle = doneTitle
    }
}

private extension KLBottomCardTableViewController {
    
    func setupNavigationBar() {
        let doneButtonItem: UIBarButtonItem
        if let doneTitle = doneTitle {
            doneButtonItem = UIBarButtonItem(title: doneTitle, style: .done, target: self, action: #selector(didDone))
        }
        else {
            doneButtonItem = UIBarButtonItem(title: "關閉", style: .done, target: self, action: #selector(didDone))
        }
        navigationItem.title = "時間表"
        navigationItem.rightBarButtonItem = doneButtonItem
        navigationBar.items = [navigationItem]
    }
    
    func setupTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.tableFooterView = UIView()
    }
    
    @objc func didDone() {
        dismiss(animated: true)
    }
}
