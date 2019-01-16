//
//  StarredCNStopModel.swift
//  EasyBus
//
//  Created by KL on 30/10/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import Foundation

class StarredCNStopModel: NSObject, NSCoding {
    
    let stopName, destCName: String
    let rdv, seq, id, route, bound, routeDescription: String
    
    init(cnBus: CNBus, cnService: CNBusService ,cnStop: CNBusStop) {
        self.stopName = cnStop.name
        self.destCName = cnBus.destName
        self.rdv = cnService.rdv
        self.seq = cnStop.stopSeq
        self.id = cnStop.stopID
        self.bound = cnBus.bound
        self.route = cnBus.route
        self.routeDescription = cnService.description
        
    }
    
    private init(stopName: String, destCName: String, id: String, rdv: String, seq: String, bound: String, route: String, routeDescription: String) {
        self.stopName = stopName
        self.id = id
        self.rdv = rdv
        self.seq = seq
        self.bound = bound
        self.route = route
        self.destCName = destCName
        self.routeDescription = routeDescription
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    // MARK: - NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(stopName, forKey: "stopName")
        aCoder.encode(id, forKey: "id")
        aCoder.encode(rdv, forKey: "rdv")
        aCoder.encode(seq, forKey: "seq")
        aCoder.encode(bound, forKey: "bound")
        aCoder.encode(route, forKey: "route")
        aCoder.encode(destCName, forKey: "destCName")
        aCoder.encode(routeDescription, forKey: "routeDescription")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let stopName = aDecoder.decodeObject(forKey: "stopName") as! String
        let id = aDecoder.decodeObject(forKey: "id") as! String
        let rdv = aDecoder.decodeObject(forKey: "rdv") as! String
        let seq = aDecoder.decodeObject(forKey: "seq") as! String
        let bound = aDecoder.decodeObject(forKey: "bound") as! String
        let route = aDecoder.decodeObject(forKey: "route") as! String
        let destCName = aDecoder.decodeObject(forKey: "destCName") as! String
        let routeDescription = aDecoder.decodeObject(forKey: "routeDescription") as! String
        
        self.init(stopName: stopName, destCName: destCName, id: id, rdv: rdv, seq: seq, bound: bound, route: route, routeDescription: routeDescription)
    }
    
    // MARK: - Equatable
    
    static func == (lhs: StarredCNStopModel, rhs: StarredCNStopModel) -> Bool {
        if (lhs.bound == rhs.bound && lhs.route == rhs.route && lhs.seq == rhs.seq && lhs.id == rhs.id && lhs.rdv == rhs.rdv) {
            return true
        }else {
            return false
        }
    }
}
