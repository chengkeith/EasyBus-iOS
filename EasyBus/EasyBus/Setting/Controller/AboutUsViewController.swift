//
//  AboutUsViewController.swift
//  EasyBus
//
//  Created by KL on 20/10/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import UIKit

class AboutUsViewController: KLTableViewController {
    
    enum Row {
        case declare
        case service
        case cnService
        case serviceHelper
        case whatsapp
        case telegram
        case developerLink
    }
    enum Section: String {
        case declare = "聲明"
        case cnService = "城巴/新巴 服務網址"
        case service = "九巴 服務網址"
        case user = "用家交流群(所有言論不代表EasyBus)"
        case developer = "開發者"
        var rows: [Row] {
            switch self {
            case .declare:
                return [.declare, .serviceHelper]
            case .cnService:
                return [.cnService]
            case .service:
                return [.service]
            case .user:
                return [.whatsapp, .telegram]
            case .developer:
                return [.developerLink]
            }
        }
    }
    var dataSource: [Section] = [.declare, .service, .user, .developer]
    
    init() {
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "關於 EasyBus"
        navigationItem.largeTitleDisplayMode = .never
        
        tableView.register(SettingBaseTableViewCell.self)
        tableView.register(ServiceSetupTableViewCell.self)
        tableView.register(CNBusServiceSetupTableViewCell.self)
    }
    
    // MARK: - tableview datasource and delegate
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].rows.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataSource[section].rawValue
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = dataSource[indexPath.section].rows[indexPath.row]
        
        switch row {
        case .declare:
            let cell: SettingBaseTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.attributedText = AboutUserViewModel.mustReadAttributedString
            return cell
        case .service:
            let cell: ServiceSetupTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.textField.placeholder = "請輸入九巴服務網址"
            cell.textField.text = UserSettingManager.shared.serviceUrl
            return cell
        case .cnService:
            let cell: CNBusServiceSetupTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.textField.placeholder = "請輸入城巴／新巴服務網址"
            cell.textField.text = UserSettingManager.shared.cnServiceUrl
            return cell
        case .serviceHelper:
            let cell: SettingBaseTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.attributedText = AboutUserViewModel.serviceHelperAttributedString
            return cell
        case .whatsapp:
            let cell: SettingBaseTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.imageView?.image = UIImage(named: "whatsapp")
            cell.textLabel?.text = "加入 WhatsApp 群組"
            return cell
        case .telegram:
            let cell: SettingBaseTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.imageView?.image = UIImage(named: "telegram")
            cell.textLabel?.text = "加入 Telegram 群組"
            return cell
        case .developerLink:
            let cell: SettingBaseTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.imageView?.image = UIImage(named: "developer")
            cell.textLabel?.text = "開發者教學"
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = dataSource[indexPath.section].rows[indexPath.row]
        
        switch row {
        case .whatsapp:
            UIApplication.shared.open(URL(string: AppManager.shared.whatsapp)!, options: [:], completionHandler: nil)
        case .telegram:
            UIApplication.shared.open(URL(string: AppManager.shared.telegram)!, options: [:], completionHandler: nil)
        case .developerLink:
            UIApplication.shared.open(URL(string: AppManager.shared.developerLink)!, options: [:], completionHandler: nil)
        default:
            return
        }
    }
}
