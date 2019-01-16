//
//  AppManager.swift
//  EasyBus
//
//  Created by KL on 16/10/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import UIKit

class AppManager {
    
    static let supportedVersion = 7
    static let shared = AppManager()
    
    var serverNotice = ""
    var appUrl = "https://itunes.apple.com/app/id1438889952"
    var whatsapp = "https://chat.whatsapp.com/GUb11y60l34IQdLS1fr4Hg"
    var telegram = "https://t.me/joinchat/K-3IhxKBsN5Bc07Md2mZcA"
    var developerLink = "https://github.com/klhui97/EasyBus-API-Guide"
    var kmbDataDownloadLink = "http://me.klhui.hk/easybus/data/"
    var payme = "https://qr.payme.hsbc.com.hk/1/41KKbzAWSEVFAYo4bm3USE"
    var paypel = "https://paypal.me/klhui"
    var alipay = "https://qr.alipay.hk/2810040101aicst8xqmv6ddlc4"
    var aboutMe = ""
    var dataVersion: Int = 0
    var dataUpdateRequired: Bool {
        return dataVersion > KMBDataManager.shared.version
    }
    
    private init() {}
    
    func config(from serverModel: ServerNoticeModel) {
        kmbDataDownloadLink = serverModel.kmbDataDownloadLink
        dataVersion = serverModel.dataVersion
        serverNotice = serverModel.message
        appUrl = serverModel.appLink
        whatsapp = serverModel.whatsapp
        telegram = serverModel.telegram
        developerLink = serverModel.developerLink
        payme = serverModel.payme
        aboutMe = serverModel.aboutMe
        paypel = serverModel.paypel
        alipay = serverModel.alipay
    }
    
    func shareApp(controller: UIViewController, soureView: UIView) {
        guard let ActivityItem = URL(string: appUrl.urlEncoded()) else { return }
        
        let objectsToShare: [Any] = [ActivityItem]
        let activityVc = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVc.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
        activityVc.popoverPresentationController?.sourceView = soureView
        controller.present(activityVc, animated: true, completion: nil)
    }
}
