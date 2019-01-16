//
//  KLTableViewController.swift
//  iOS Practice
//
//  Created by KL on 15/8/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import UIKit

class KLTableViewController: UITableViewController, HasLoadingOverlay {
    
    typealias ReloadFunction = () -> Void
    var loadingOverlay: LoadingOverlay?
    
    override init(style: UITableViewStyle = .plain) {
        super.init(style: style)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.tableFooterView = UIView()
    }
    
    func reloadWithoutScrolling(reloadFunction: ReloadFunction) {
        let lastScrollOffset = tableView.contentOffset
        tableView.beginUpdates()
        reloadFunction()
        tableView.endUpdates()
        tableView.layer.removeAllAnimations()
        tableView.setContentOffset(lastScrollOffset, animated: false)
    }
}
