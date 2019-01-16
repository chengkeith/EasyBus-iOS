//
//  EtaModel.swift
//  EasyBus
//
//  Created by KL on 14/10/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import Foundation

struct EtaResultModel: Codable {
    let success: Bool?
    let responsecode: Int?
    let etas: [EtaModel]
    
    enum CodingKeys: String, CodingKey {
        case success
        case responsecode
        case etas = "response"
    }
}

struct EtaModel: Codable {
    let w: String?
    let ei: String?
    let displayTime: String
    let busServiceType: Int?
    let ex: String
    
    var exactArrivialTime: String {
        if var date = DateHelper.stringToDate(dateString: ex) {
            // subtract one second from the real arrvial time
            date.addTimeInterval(-60)
            return DateHelper.dateToString(date: date) ?? ex
        }
        return ex
    }
    
    enum CodingKeys: String, CodingKey {
        case w, ei, ex
        case displayTime = "t"
        case busServiceType = "bus_service_type"
    }
}
