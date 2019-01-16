//
//  ServerAdminModel.swift
//  EasyBus
//
//  Created by KL on 16/10/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import Foundation

struct ServerNoticeModel: Codable {
    let success: Bool
    let supportVersion: Int
    let updateTitle: String
    let updateMessage: String
    let alipay: String
    let payme: String
    let paypel: String
    let aboutMe: String
    let dataVersion: Int
    let kmbDataDownloadLink: String
    let message: String
    let whatsapp: String
    let telegram: String
    let developerLink: String
    let appLink: String
    let kmbServiceLink: String
    let cityBusServiceLink: String
    let enableAutoSetService: Bool
}

struct APIResponse: Codable {
    
    var success: Bool
    var errorMessage: String?
}
