//
//  StarredStopModel.swift
//  EasyBus
//
//  Created by KL on 14/10/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import Foundation

class StarredStopModel: NSObject, StopQeuriable, NSCoding {

    let cName, destCName: String
    let airFare, serviceType: String
    let bsiCode, seq, bound, route: String
    
    init(busModel: BusData, stopModel: StopData) {
        self.cName = stopModel.cName
        self.airFare = stopModel.airFare
        self.serviceType = stopModel.serviceType
        self.bsiCode = stopModel.bsiCode
        self.seq = stopModel.seq
        self.bound = stopModel.bound
        self.route = stopModel.route
        self.destCName = busModel.destCName
    }
    
    private init(cName: String, destCName: String, airFare: String, serviceType: String, bsiCode: String, seq: String, bound: String, route: String) {
        self.cName = cName
        self.airFare = airFare
        self.serviceType = serviceType
        self.bsiCode = bsiCode
        self.seq = seq
        self.bound = bound
        self.route = route
        self.destCName = destCName
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    // MARK: - NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(cName, forKey: "cName")
        aCoder.encode(airFare, forKey: "airFare")
        aCoder.encode(serviceType, forKey: "serviceType")
        aCoder.encode(bsiCode, forKey: "bsiCode")
        aCoder.encode(seq, forKey: "seq")
        aCoder.encode(bound, forKey: "bound")
        aCoder.encode(route, forKey: "route")
        aCoder.encode(destCName, forKey: "destCName")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let cName = aDecoder.decodeObject(forKey: "cName") as! String
        let airFare = aDecoder.decodeObject(forKey: "airFare") as! String
        let serviceType = aDecoder.decodeObject(forKey: "serviceType") as! String
        let bsiCode = aDecoder.decodeObject(forKey: "bsiCode") as! String
        let seq = aDecoder.decodeObject(forKey: "seq") as! String
        let bound = aDecoder.decodeObject(forKey: "bound") as! String
        let route = aDecoder.decodeObject(forKey: "route") as! String
        let destCName = aDecoder.decodeObject(forKey: "destCName") as! String
        
        self.init(cName: cName, destCName: destCName, airFare: airFare, serviceType: serviceType, bsiCode: bsiCode, seq: seq, bound: bound, route: route)
    }
    
    // MARK: - Equatable
    
    static func == (lhs: StarredStopModel, rhs: StarredStopModel) -> Bool {
        if (lhs.bound == rhs.bound && lhs.bsiCode == rhs.bsiCode && lhs.seq == rhs.seq && lhs.serviceType == rhs.serviceType && lhs.route == rhs.route) {
            return true
        }else {
            return false
        }
    }
}
