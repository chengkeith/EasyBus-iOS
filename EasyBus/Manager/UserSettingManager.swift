//
//  UserSettingManager.swift
//  EasyBus
//
//  Created by KL on 16/10/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import UIKit
import UserNotifications
import SCLAlertView

class UserSettingManager: NSObject {
    
    static let shared = UserSettingManager()
    var isAllowPush: Bool {
        didSet {
            UserDefaults.standard.set(isAllowLocation, forKey: UserSetting.push.key)
            if isAllowPush {
                UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound], completionHandler: {(granted, error) in
                    if granted {
                        DispatchQueue.main.async {
                            UIApplication.shared.registerForRemoteNotifications()
                        }
                    }
                    if error != nil {
                        self.isAllowPush = false
                        SCLAlertView().showWarning("沒有權限", subTitle: "請在設定－>EasyApp－>充許通知", closeButtonTitle: "確定")
                    }
                })
            }else {
                APIManager.shared.removePush()
            }
        }
    }
    var isAllowLocation: Bool {
        didSet {
            UserDefaults.standard.set(isAllowLocation, forKey: UserSetting.location.key)
        }
    }
    var etaFrequency: EtaFrequencyOption {
        didSet {
            UserDefaults.standard.set(etaFrequency.rawValue, forKey: UserSetting.etaFrequency.key)
        }
    }
    var nearbyDistance: ShowNearbyOption {
        didSet {
            UserDefaults.standard.set(nearbyDistance.rawValue, forKey: UserSetting.nearbyDistance.key)
        }
    }
    var serviceUrl: String {
        didSet {
            UserDefaults.standard.set(serviceUrl, forKey: UserSetting.serviceUrl.key)
        }
    }
    var cnServiceUrl: String {
        didSet {
            UserDefaults.standard.set(cnServiceUrl, forKey: UserSetting.cnServiceUrl.key)
        }
    }
    var hideTips: Bool {
        didSet {
            UserDefaults.standard.set(hideTips, forKey: UserSetting.hideTips.key)
        }
    }
    var showExactTime: Bool {
        didSet {
            UserDefaults.standard.set(showExactTime, forKey: UserSetting.showExactTime.key)
        }
    }
    var appStartTabIndex: Int {
        didSet {
            UserDefaults.standard.set(appStartTabIndex, forKey: UserSetting.appStartTab.key)
        }
    }
    
    override init() {
        let exampleUrl = "http://159.89.196.81:9999/example"
        UserDefaults.standard.register(defaults: [UserSetting.appStartTab.key : 2,
                                                  UserSetting.serviceUrl.key: exampleUrl,
                                                  UserSetting.cnServiceUrl.key: exampleUrl,
                                                  UserSetting.showExactTime.key: false])
        
        // VIP
//        UserDefaults.standard.register(defaults: [UserSetting.serviceUrl.key: "http://40.83.75.233",
//                                                  UserSetting.cnServiceUrl.key: "http://172.217.24.206"])
        
        
        
        appStartTabIndex = UserDefaults.standard.integer(forKey: UserSetting.appStartTab.key)
        isAllowPush = UserDefaults.standard.bool(forKey: UserSetting.push.key)
        etaFrequency = EtaFrequencyOption(rawValue: UserDefaults.standard.integer(forKey: UserSetting.etaFrequency.key)) ?? EtaFrequencyOption.normal
        serviceUrl = UserDefaults.standard.string(forKey: UserSetting.serviceUrl.key) ?? exampleUrl
        cnServiceUrl = UserDefaults.standard.string(forKey: UserSetting.cnServiceUrl.key) ?? exampleUrl
        isAllowLocation = UserDefaults.standard.bool(forKey: UserSetting.location.key)
        showExactTime = UserDefaults.standard.bool(forKey: UserSetting.showExactTime.key)
        nearbyDistance = ShowNearbyOption(rawValue: UserDefaults.standard.integer(forKey: UserSetting.nearbyDistance.key)) ?? ShowNearbyOption.near
        hideTips = UserDefaults.standard.bool(forKey: UserSetting.hideTips.key)
        super.init()
    }
}

enum UserSetting: String {
    case appStartTab = "開App主頁"
    case push = "推送通知"
    case showExactTime = "顯示詳細到站時間"
    case location = "定位服務"
    case etaFrequency = "到站時間間隔"
    case nearbyDistance = "顯示最近車站距離限制"
    case serviceUrl = "服務網址"
    case cnServiceUrl = "城巴服務網址"
    case hideTips = "隱藏提示"
    
    var key: String {
        switch self {
        case .appStartTab:
            return "appStartTab"
        case .showExactTime:
            return "showExactTime"
        case .nearbyDistance:
            return "nearbyDistance"
        case .cnServiceUrl:
            return "cnServiceUrl"
        case .push:
            return "isAllowPush"
        case .location:
            return "isAllowLocation"
        case .etaFrequency:
            return "etaFrequency"
        case .serviceUrl:
            return "serviceUrl"
        case .hideTips:
            return "hideTips"
        }
    }
}

enum EtaFrequencyOption: Int {
    
    case fast = 2
    case normal = 1
    case slow = 0
    
    // stringArray need to follow the rawValue order
    static var stringArray: [String] = [EtaFrequencyOption.slow.stringValue, EtaFrequencyOption.normal.stringValue, EtaFrequencyOption.fast.stringValue]
    
    var stringValue: String {
        switch self {
        case .fast:
            return "25 秒"
        case .normal:
            return "45 秒"
        case .slow:
            return "60 秒"
        }
    }
    
    var timeInterval: TimeInterval {
        switch self {
        case .fast:
            return 25
        case .normal:
            return 45
        case .slow:
            return 60
        }
    }
}

enum ShowNearbyOption: Int {
    
    case notLimited = 3
    case far = 2
    case normal = 1
    case near = 0
    
    // stringArray need to follow the rawValue order
    static var stringArray: [String] = [ShowNearbyOption.near.stringValue, ShowNearbyOption.normal.stringValue, ShowNearbyOption.far.stringValue, ShowNearbyOption.notLimited.stringValue]
    
    var stringValue: String {
        switch self {
        case .near:
            return "500 米內"
        case .normal:
            return "1 公里內"
        case .far:
            return "2 公里內"
        case .notLimited:
            return "不限"
        }
    }
    
    var distance: Double {
        switch self {
        case .near:
            return 500
        case .normal:
            return 1000
        case .far:
            return 2000
        case .notLimited:
            return 500000
        }
    }
}
