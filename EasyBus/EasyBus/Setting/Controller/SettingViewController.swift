//
//  SettingViewController.swift
//  EasyBus
//
//  Created by KL on 12/10/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import UIKit
import Material
import CoreLocation
import SCLAlertView

class SettingViewController: KLTableViewController, PremissionTableViewCellProtocol, CLLocationManagerDelegate {
    
    enum Row {
        case share, version, message, pushPremission, locationPremission
        case etaFrequency, nearbyDistance, aboutUs, dataUpdate
        case showExactTime, donate, appStartTab
    }
    enum Section: String {
        case permission = "權限"
        case app = "EasyBus"
        case notice = "公告"
        case accuracy = "精準度"
        case display = "顯示"
        
        var rows: [Row] {
            switch self {
            case .display:
                return [.showExactTime, .appStartTab]
            case .accuracy:
                return [.locationPremission, .etaFrequency, .nearbyDistance]
            case .permission:
                return []
            case .app:
                return [.aboutUs, .dataUpdate, .share, .pushPremission, .donate]
            case .notice:
                return [.version, .message]
            }
        }
    }
    let locationManager = CLLocationManager()
//    let googleAdManager = GoogleAdManager()
    
    var dataSource: [Section] = [.app, .accuracy, .display, .notice]
    
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
        
        let shareBarButtonItem = UIBarButtonItem(image: Icon.cm.share,
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(shareBarButtonItemOnClicked))
        navigationItem.rightBarButtonItem = shareBarButtonItem
        navigationItem.removeBackButtonText()
        navigationItem.title = "設定"
        locationManager.delegate = self
        
        tableView.register(SettingBaseTableViewCell.self)
        tableView.register(PremissionTableViewCell.self)
    }
    
    @objc func shareBarButtonItemOnClicked() {
        AppManager.shared.shareApp(controller: self, soureView: tableView)
    }
    
    // MARK: - Method
    
    func reloadRow(rowType: Row) {
        for (sectionIndex, section) in dataSource.enumerated() {
            let rowI = section.rows.firstIndex { $0 == rowType }
            if let rowIndex = rowI {
                UIView.performWithoutAnimation {
                    self.tableView.beginUpdates()
                    self.tableView.reloadRows(at: [IndexPath(row: rowIndex, section: sectionIndex)], with: .none)
                    self.tableView.endUpdates()
                }
            }
        }
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
        case .appStartTab:
            let cell: SettingBaseTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.imageView?.image = Icon.visibility
            cell.textLabel?.attributedText = UserSettingViewModel.attributedValueSetting(prefix: "開App首頁  ", key: TabBar(rawValue: UserSettingManager.shared.appStartTabIndex)?.accessibilityLabel ?? "")
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .default
            return cell
        case .donate:
            let cell: SettingBaseTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.imageView?.image = #imageLiteral(resourceName: "ic_donation")
            cell.textLabel?.attributedText = UserSettingViewModel.donateAttributedString
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .default
            return cell
        case .dataUpdate:
            let cell: SettingBaseTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.imageView?.image = #imageLiteral(resourceName: "ic_update")
            cell.textLabel?.attributedText = UserSettingViewModel.updateDataAttributedString
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .default
            return cell
        case .nearbyDistance:
            let cell: SettingBaseTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            if UserSettingManager.shared.isAllowLocation {
                cell.textLabel?.attributedText = UserSettingViewModel.attributedValueSetting(prefix: "優先顯示最近的車站  ", key: UserSettingManager.shared.nearbyDistance.stringValue)
            }else {
                cell.textLabel?.attributedText = UserSettingViewModel.attributedValueSetting(prefix: "優先顯示最近的車站  ", key: "請先開啟定位")
            }
            cell.imageView?.image = Icon.search
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .default
            return cell
        case .etaFrequency:
            let cell: SettingBaseTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.textLabel?.attributedText = UserSettingViewModel.attributedValueSetting(prefix: "到站時間自動更新:  每 ", key: UserSettingManager.shared.etaFrequency.stringValue, postfix: " 一次")
            cell.accessoryType = .disclosureIndicator
            cell.imageView?.image = Icon.flashOn
            cell.selectionStyle = .default
            return cell
        case .share:
            let cell: SettingBaseTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.imageView?.image = Icon.cm.share
            cell.textLabel?.attributedText = UserSettingViewModel.attributedValueSetting(prefix: "分享EasyBus")
            cell.accessoryType = .disclosureIndicator
            return cell
        case .pushPremission:
            let cell: PremissionTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.delegate = self
            cell.indexPath = indexPath
            cell.imageView?.image = Icon.cm.bell
            cell.enableSwitch.isOn = UserSettingManager.shared.isAllowPush
            cell.textLabel?.attributedText = UserSettingViewModel.attributedValueSetting(prefix: UserSetting.push.rawValue)
            return cell
        case .showExactTime:
            let cell: PremissionTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.delegate = self
            cell.imageView?.image = #imageLiteral(resourceName: "ic_alarm")
            cell.indexPath = indexPath
            cell.enableSwitch.isOn = UserSettingManager.shared.showExactTime
            cell.textLabel?.attributedText = UserSettingViewModel.attributedValueSetting(prefix: UserSetting.showExactTime.rawValue)
            return cell
        case .locationPremission:
            let cell: PremissionTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.delegate = self
            cell.imageView?.image = Icon.place
            cell.indexPath = indexPath
            cell.enableSwitch.isOn = UserSettingManager.shared.isAllowLocation
            cell.textLabel?.attributedText = UserSettingViewModel.attributedValueSetting(prefix: UserSetting.location.rawValue)
            return cell
        case .version:
            let cell: SettingBaseTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.imageView?.image = UIImage(named: "ic_version")
            cell.textLabel?.attributedText = UserSettingViewModel.attributedValueSetting(prefix: "版本: ", key: VersionManager.versionString)
            return cell
        case .message:
            let cell: SettingBaseTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.attributedText = UserSettingViewModel.attributedBody(body: AppManager.shared.serverNotice)
            return cell
        case .aboutUs:
            let cell: SettingBaseTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.imageView?.image = Icon.star
            cell.selectionStyle = .default
            cell.accessoryType = .detailDisclosureButton
            cell.textLabel?.attributedText = UserSettingViewModel.aboutUsAttributedString
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let row = dataSource[indexPath.section].rows[indexPath.row]
        
        switch row {
        case .share:
            AppManager.shared.shareApp(controller: self, soureView: tableView)
        case .etaFrequency:
            showEtaFrequencyPicker()
        case .nearbyDistance:
            if UserSettingManager.shared.isAllowLocation {
                showNearbyDistancePicker()
            }
        case .appStartTab:
            showAppStartTabPicker()
        case .donate:
            FirebaseAnalytics.shared.logEventWithDeviceId(eventName: "donate_open")
            navigationController?.pushViewController(DonateViewController(), animated: true)
        case .aboutUs:
            navigationController?.pushViewController(AboutUsViewController(), animated: true)
        case .dataUpdate:
            let vc = DataUpdateViewController()
            navigationController?.pushViewController(vc, animated: true)
        default:
            return
        }
    }
    
    // MARK: - start app setting
    
    func showAppStartTabPicker() {
        let items = TabBar.array.map { (tab) -> String in
            tab.accessibilityLabel
        }
        let pickerViewController = KLPickerViewController(items: items, selectedIndex: UserSettingManager.shared.appStartTabIndex) { (i) in
            if TabBar(rawValue: i) != nil {
                UserSettingManager.shared.appStartTabIndex = i
                self.reloadRow(rowType: .appStartTab)
            }
        }
        
        tabBarController?.present(pickerViewController, animated: true)
    }
    
    // MARK: - Accuracy
    
    func showEtaFrequencyPicker() {
        let pickerViewController = KLPickerViewController(items: EtaFrequencyOption.stringArray, selectedIndex: UserSettingManager.shared.etaFrequency.rawValue) { (i) in
            if let option = EtaFrequencyOption(rawValue: i) {
                UserSettingManager.shared.etaFrequency = option
                self.reloadRow(rowType: .etaFrequency)
            }
        }
        tabBarController?.present(pickerViewController, animated: true)
    }
    
    func showNearbyDistancePicker() {
        let pickerViewController = KLPickerViewController(items: ShowNearbyOption.stringArray, selectedIndex: UserSettingManager.shared.nearbyDistance.rawValue) { (i) in
            if let option = ShowNearbyOption(rawValue: i) {
                UserSettingManager.shared.nearbyDistance = option
                self.reloadRow(rowType: .nearbyDistance)
            }
        }
        tabBarController?.present(pickerViewController, animated: true)
    }
    
    // MARK: - PremissionTableViewCellProtocol
    
    func didTapSiwtch(tapSwitch: UISwitch, indexPath: IndexPath) {
        let row = dataSource[indexPath.section].rows[indexPath.row]
        
        switch row {
        case .locationPremission:
            let status = CLLocationManager.authorizationStatus()
            if tapSwitch.isOn {
                switch status {
                case .authorizedWhenInUse:
                    UserSettingManager.shared.isAllowLocation = true
                case .notDetermined:
                    tapSwitch.isOn = false
                    locationManager.requestWhenInUseAuthorization()
                case .denied, .restricted:
                    tapSwitch.isOn = false
                    SCLAlertView().showWarning("無法取得定位服務權限", subTitle: "請於設定－>EasyBus－>位置－>充許取用位置－使用App時", closeButtonTitle: "確定")
                default: break
                }
            }else {
                UserSettingManager.shared.isAllowLocation = false
            }
            reloadRow(rowType: .locationPremission)
            reloadRow(rowType: .nearbyDistance)
        case .pushPremission:
            UserSettingManager.shared.isAllowPush = tapSwitch.isOn
        case .showExactTime:
            UserSettingManager.shared.showExactTime = tapSwitch.isOn
        default:
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == .authorizedWhenInUse) {
            UserSettingManager.shared.isAllowLocation = true
            reloadRow(rowType: .locationPremission)
            reloadRow(rowType: .nearbyDistance)
        }
    }
}
