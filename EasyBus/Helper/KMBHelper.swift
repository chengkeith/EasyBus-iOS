//
//  KMBHelper.swift
//  EasyBus
//
//  Created by KL on 20/11/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import UIKit
import CoreLocation

class KMBHelper {
    
    static let shared = KMBHelper()
    var range: Double = 300
    
    func getNearbyBusStop(fromLat: Double, fromLong: Double, toLat: Double, toLong: Double) -> [AnalyzeStopViewModel] {
        let fromLocation = CLLocation(latitude: fromLat, longitude: fromLong)
        let toLocation = CLLocation(latitude: toLat, longitude: toLong)
        
        return KMBDataManager.shared.busViewModel.compactMap({ (viewModel) -> AnalyzeStopViewModel? in
            let bus = viewModel.busData
            
            guard let startStop = getNearestStop(at: bus, relativeTo: fromLocation, maxDistance: range), let startStopIndex = bus.stops.firstIndex(where: { $0.bsiCode == startStop.bsiCode }) else { return nil }
            guard startStopIndex + 1 < bus.stops.count else { return nil}
            let options = Array(bus.stops[startStopIndex + 1..<bus.stops.count])
            guard let endStop = getNearestStop(stops: options, relativeTo: toLocation, maxDistance: range) else { return nil }
            return AnalyzeStopViewModel(startStop: StarredStopModel(busModel: bus, stopModel: startStop), endStop: StarredStopModel(busModel: bus, stopModel: endStop))
        })
    }
    
    func getNearestStop(at bus: BusData, relativeTo: CLLocation, maxDistance: Double) -> StopData? {
        return getNearestStop(stops: bus.stops, relativeTo: relativeTo, maxDistance: maxDistance)
    }
    
    func getNearestStop(stops: [StopData], relativeTo: CLLocation, maxDistance: Double) -> StopData? {
        var minDistance = maxDistance
        var nearestStop: StopData?
        
        stops.forEach { (stop) in
            let distance = LocationDistanceHelper.distance(loc1: relativeTo, lat2: stop.lat, lon2: stop.long)
            if distance <= minDistance {
                minDistance = distance
                nearestStop = stop
            }
        }
        return nearestStop
    }
}
