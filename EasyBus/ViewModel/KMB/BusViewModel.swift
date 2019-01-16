//
//  BusViewModel.swift
//  EasyBus
//
//  Created by KL on 13/10/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import UIKit
import CoreLocation

class BusViewModel: NSObject {
    
    var busData: BusData
    var route: String {
        if (busData.serviceType == 1) {
            return busData.route
        }else {
            return busData.route + "!"
        }
    }
    var direction: NSAttributedString {
        let sentence = "往" + busData.destCName
        
        let attributedSentence = NSMutableAttributedString(string: sentence, attributes: EtaAttribute.darkGrayLargeRegularSemibold)
        attributedSentence.setAttributes(EtaAttribute.smallRegular, range: NSRange(location: 0, length: 1))
        
        if (busData.serviceTypeTc != "") {
            let attributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12),
                              NSAttributedStringKey.foregroundColor: UIColor.lightGray]
            let serviceTypeAttributedString = NSMutableAttributedString(string: "\n\n" + busData.serviceTypeTc, attributes: attributes)
            attributedSentence.append(serviceTypeAttributedString)
        }
        return attributedSentence
    }
    var navigationTitle: String {
        return busData.route + " – 往 " + busData.destCName
    }
    lazy var stopViewModels: [StopViewModel] = {
        return self.busData.stops.map({ (stopData) -> StopViewModel in
            return StopViewModel(stopData: stopData)
        })
    }()
    
    init(busData: BusData) {
        self.busData = busData
    }
    
    func nearestStarredStopViewModel(compareWith: CLLocation, in range: Double) -> NearbyStopViewModel? {
        var nearestStop: StopData?
        var nearestDistance: Double?
        for stop in busData.stops {
            let distance = LocationDistanceHelper.distance(loc1: compareWith, loc2: CLLocation(latitude: stop.lat, longitude: stop.long))
            
            if distance <= range {
                if let nDistance = nearestDistance, distance < nDistance {
                    nearestDistance = distance
                    nearestStop = stop
                }else if nearestDistance == nil {
                    nearestDistance = distance
                    nearestStop = stop
                }
                
            }
        }
        guard let stop = nearestStop, let distance = nearestDistance else { return nil }
        return NearbyStopViewModel(starredStopModel: StarredStopModel(busModel: busData, stopModel: stop), busData: busData, distance: distance)
    }
}
