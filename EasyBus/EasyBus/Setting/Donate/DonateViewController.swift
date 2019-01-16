//
//  DonateViewController.swift
//  EasyBus
//
//  Created by KL on 29/10/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import UIKit
import MessageUI
import StoreKit

class DonateViewController: KLTableViewController, MFMailComposeViewControllerDelegate {
    
    enum Row {
        case aboutMe
        case payme
        case paypel
        case alipay
        case email
        case wechatpay
        case review
    }
    
    enum Section: String {
        case aboutMe = "關於"
        case donate = "EasyBus好用嗎？請我飲一杯咖啡？"
        case contact = "聯絡開發者"
        case review = "或者留下一個五星好評及評論，以支持繼續開發EasyBus"
        
        var rows: [Row] {
            switch self {
            case .aboutMe:
                return [.aboutMe]
            case .donate:
                return [.payme, .alipay, .paypel]
            case .contact:
                return [.email]
            case .review:
                return [.review]
            }
        }
    }
    
    var dataSource: [Section] = [.aboutMe, .donate, .review, .contact]
    
    init() {
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "支持開發者"
        tableView.register(SettingBaseTableViewCell.self)
    }
    
    // MARK: - TableView datasource and delegate
    
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
        return 50
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = dataSource[indexPath.section].rows[indexPath.row]
        
        switch row {
        case .review:
            let cell: SettingBaseTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.text = "點此開啟評分功能"
            cell.selectionStyle = .default
            return cell
        case .aboutMe:
            let cell: SettingBaseTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.textLabel?.text = AppManager.shared.aboutMe
            cell.selectionStyle = .default
            return cell
        case .payme:
            let cell: SettingBaseTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.imageView?.image = #imageLiteral(resourceName: "ic_payme")
            cell.textLabel?.text = "使用 PayMe"
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .default
            return cell
        case .paypel:
            let cell: SettingBaseTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.imageView?.image = #imageLiteral(resourceName: "ic_paypal")
            cell.textLabel?.text = "使用 PayPal"
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .default
            return cell
        case .wechatpay:
            let cell: SettingBaseTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.imageView?.image = #imageLiteral(resourceName: "ic_wechatpay")
            cell.textLabel?.text = "使用 WeChat Pay"
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .default
            return cell
        case .alipay:
            let cell: SettingBaseTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.imageView?.image = #imageLiteral(resourceName: "ic_alipay")
            cell.textLabel?.text = "使用 支付寶"
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .default
            return cell
        case .email:
            let cell: SettingBaseTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.imageView?.image = #imageLiteral(resourceName: "ic_chat")
            cell.textLabel?.text = "電郵聯絡"
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .default
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let row = dataSource[indexPath.section].rows[indexPath.row]
        
        switch row {
        case .review:
            FirebaseAnalytics.shared.logEventWithDeviceId(eventName: "donate_review")
            SKStoreReviewController.requestReview()
        case .payme:
            FirebaseAnalytics.shared.logEventWithDeviceId(eventName: "donate_payme")
            if let url = URL(string: AppManager.shared.payme) {
                UIApplication.shared.open(url, options: [:])
            }
        case .paypel:
            FirebaseAnalytics.shared.logEventWithDeviceId(eventName: "donate_paypel")
            if let url = URL(string: AppManager.shared.paypel) {
                UIApplication.shared.open(url, options: [:])
            }
        case .alipay:
            FirebaseAnalytics.shared.logEventWithDeviceId(eventName: "donate_alipay")
            if let url = URL(string: AppManager.shared.alipay) {
                UIApplication.shared.open(url, options: [:])
            }
        case .wechatpay:
            FirebaseAnalytics.shared.logEventWithDeviceId(eventName: "donate_wechatpay")
        case .email:
            FirebaseAnalytics.shared.logEventWithDeviceId(eventName: "donate_email")
            iOSMessageManager.showEmail(presenter: self, delegate: self, emailTitle: "[EasyBus]", toRecipients: ["me@klhui.hk"])
        default:
            break
        }
    }
    
    // MARK: - MFMailComposeViewControllerDelegate
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
}
