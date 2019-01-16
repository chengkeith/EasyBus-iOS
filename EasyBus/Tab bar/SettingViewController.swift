//
//  SettingViewController.swift
//  EasyBus
//
//  Created by KL on 12/10/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import UIKit

class SettingViewController: KLTableViewController {
    
    enum Row {
        case version
        case message
    }
    var rows: [Row] = [.version, .message]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "設定"
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = rows[indexPath.row]
        
        switch row {
        case .version:
            let cell = UITableViewCell()
            cell.textLabel?.text = "beta v1.0"
            return cell
        case .message:
            let cell = UITableViewCell()
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = """
            未來功能:
            巴士站分類及收藏
            自訂通知(提醒巴士到站時間)
            定位功能
            """
            return cell
        }
    }
}
