//
//  NearbyStopViewModel.swift
//  EasyBus
//
//  Created by KL on 21/10/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import UIKit
import CoreLocation

class NearbyStopViewModel: StarredStopViewModel {
    
    let busData: BusData
    let distance: Double
    
    init(starredStopModel: StarredStopModel, busData: BusData, distance: Double) {
        self.busData = busData
        self.distance = distance
        super.init(starredStopModel: starredStopModel)
    }
}
