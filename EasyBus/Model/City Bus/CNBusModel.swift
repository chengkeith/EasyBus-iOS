//
//  CNBusModel.swift
//  EasyBus
//
//  Created by KL on 28/10/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import Foundation

struct CNBusListAPIResponse: Codable {
    let success: Bool
    let buses: [CNBus]?
}

struct CNBus: Codable {
    let busType: CNBusType
    let route, destCode, oriName, destName: String
    let id, bound: String
}

enum CNBusType: String, Codable {
    case ctb = "CTB"
    case nwfb = "NWFB"
}

struct CNBusServiceAPIResponse: Codable {
    let success: Bool
    let service: [CNBusService]?
}

struct CNBusService: Codable {
    let rdv, description, qInfo, color: String
}

struct CNBusStopsAPIResponse: Codable {
    let success: Bool
    let stops: [CNBusStop]?
}

struct CNBusStop: Codable {
    let stopSeq, stopID: String
    let lat, long: Double
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case stopSeq
        case stopID = "stopId"
        case lat, long, name
    }
}

struct CNBusNearbyAPIResponse: Codable {
    let success: Bool
    let buses: [CNBus]?
}
