//
//  SmartAnalyzeModel.swift
//  EasyBus
//
//  Created by KL on 2/12/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import UIKit

class SmartAnalyzeModel: NSObject, NSCoding {
    
    let startLat, startLong: Double
    let endLat, endLong: Double
    let name: String
    
    init(name: String, startStop: StopData, endStop: StopData) {
        self.name = name
        self.startLat = startStop.lat
        self.startLong = startStop.long
        self.endLat = endStop.lat
        self.endLong = endStop.long
    }
    
    private init(name: String, startLat: Double, startLong: Double, endLat: Double, endLong: Double) {
        self.name = name
        self.startLat = startLat
        self.startLong = startLong
        self.endLat = endLat
        self.endLong = endLong
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    // MARK: - NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(startLat, forKey: "startLat")
        aCoder.encode(startLong, forKey: "startLong")
        aCoder.encode(endLat, forKey: "endLat")
        aCoder.encode(endLong, forKey: "endLong")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObject(forKey: "name") as! String
        let startLat = aDecoder.decodeDouble(forKey: "startLat")
        let startLong = aDecoder.decodeDouble(forKey: "startLong")
        let endLat = aDecoder.decodeDouble(forKey: "endLat")
        let endLong = aDecoder.decodeDouble(forKey: "endLong")
        
        self.init(name: name, startLat: startLat, startLong: startLong, endLat: endLat, endLong: endLong)
    }
    
    // MARK: - Equatable
    
    static func == (lhs: SmartAnalyzeModel, rhs: SmartAnalyzeModel) -> Bool {
        if (lhs.name == rhs.name && lhs.startLat == rhs.startLat && lhs.startLong == rhs.startLong && lhs.endLat == rhs.endLat && lhs.endLong == rhs.endLong) {
            return true
        }else {
            return false
        }
    }
}
