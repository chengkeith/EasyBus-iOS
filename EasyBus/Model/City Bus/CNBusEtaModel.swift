//
//  CityBusEtaModel.swift
//  EasyBus
//
//  Created by KL on 28/10/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import Foundation

struct CNBusEtaAPIResponse: Codable {
    let success: Bool
    let response: [CNBusEtaModel]?
}

struct CNBusEtaModel: Codable {
    let distance, direction, time: String
}
