//
//  LocationDistanceHelper.swift
//  EasyBus
//
//  Created by KL on 17/10/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import UIKit
import CoreLocation

class LocationDistanceHelper {
    
    static func distance(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
        let loc1 = CLLocation(latitude: lat1, longitude: lon1)
        let loc2 = CLLocation(latitude: lat2, longitude: lon2)
        
        return distance(loc1: loc1, loc2: loc2)
    }
    
    static func distance(loc1: CLLocation, lat2: Double, lon2: Double) -> Double {
        let loc2 = CLLocation(latitude: lat2, longitude: lon2)
        
        return distance(loc1: loc1, loc2: loc2)
    }
    
    static func distance(loc1: CLLocation, loc2: CLLocation) -> Double {
        return loc1.distance(from: loc2)
    }
}
