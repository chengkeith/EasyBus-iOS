//
//  KMBResultModel.swift
//  EasyBus
//
//  Created by KL on 12/10/2018.
//  Copyright © 2018 KL. All rights reserved.
//

// To parse the JSON, add this file to your project and do:
//
//   let welcome = try? newJSONDecoder().decode(Welcome.self, from: jsonData)

import Foundation

struct KMBResultModel: Codable {
    let version: Int
    let keyboards: [[String]]
    let result: [BusData]
}

struct BusData: Codable {
    let route: String
    let bound, serviceType: Int16
    let stops: [StopData]
    let specialRoute: String?
    let oriCName, destCName, serviceTypeTc: String
//    let oriSCName, oriEName, destSCName, destEName, : String
    
    enum CodingKeys: String, CodingKey {
        case route = "Route"
        case specialRoute = "Special"
        case bound = "BOUND"
        case serviceType = "Services"
        case stops = "Stops"
        case oriCName = "OriCName"
//        case oriSCName = "OriSCName"
//        case oriEName = "OriEName"
        case destCName = "DestCName"
//        case destSCName = "DestSCName"
//        case destEName = "DestEName"
        case serviceTypeTc = "ServiceTypeTC"
    }
}

struct StopData: Codable, StopQeuriable {
    let cName, cLocation, airFare, serviceType: String
//    let scLocation, eLocation, eName, scName: String
    let bsiCode, seq, bound, route: String
    let lat, long: Double
    
    enum CodingKeys: String, CodingKey {
//        case scName = "SCName"
//        case eName = "EName"
        case cName = "CName"
        case cLocation = "CLocation"
//        case scLocation = "SCLocation"
//        case eLocation = "ELocation"
        case airFare = "AirFare"
        case serviceType = "ServiceType"
        case bsiCode = "BSICode"
        case seq = "Seq"
        case bound = "Bound"
        case route = "Route"
        case lat = "lat"
        case long = "long"
    }
}

protocol StopQeuriable {
    var bsiCode: String { get }
    var seq: String { get }
    var bound: String { get }
    var route: String { get }
    var serviceType: String { get }
}

struct KMBScheduleAPIResponse: Codable {
    let data: [String: [KMBScheduleModel]]
    let result: Bool
}

struct KMBScheduleModel: Codable {
    let dayType, boundTime1, boundText1, boundTime2, boundText2, orderSeq, serviceType: String
    
    var dayString: String {
        let code = dayType.trimmingCharacters(in: .whitespaces)
        
        switch code {
        case "MF", "W":
            return "星期一至星期五"
        case "MS":
            return "星期一至星期六"
        case "S":
            return "星期六"
        case "D":
            return "每天"
        case "H":
            return "星期日及公眾假期"
        default: return " "
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case dayType = "DayType"
        case boundTime1 = "BoundTime1"
        case boundText1 = "BoundText1"
        case boundTime2 = "BoundTime2"
        case boundText2 = "BoundText2"
        case orderSeq = "OrderSeq"
        case serviceType = "ServiceType_Chi"
    }
    
    func getBoundTime(bound: Int) -> String {
        if bound == 1 {
            return boundTime1
        }else {
            return boundTime2
        }
    }
    
    func getBoundText(bound: Int) -> String {
        if bound == 1 {
            return boundText1
        }else {
            return boundText2
        }
    }
    
    func isCurrentPeriod(bound: Int) -> Bool {
        let boundText = getBoundText(bound: bound)
        let timeStringArray = boundText.split(separator: "-")
        
        if timeStringArray.count == 1 {
            return true
        }else  if timeStringArray.count == 2 {
            var dates = timeStringArray.compactMap { (s) -> Date? in
                return DateHelper.stringToDate(dateFormat: "HH:mm", dateString: s.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: "*", with: ""))
            }
            guard dates.count == 2, let currentTime = DateHelper.dateToString(dateFormat: "HH:mm", date: DateHelper.now), let now = DateHelper.stringToDate(dateFormat: "HH:mm", dateString: currentTime) else { return false }
            
            if dates[1] < dates[0] {
                dates[1] = dates[1].addingTimeInterval(60 * 60 * 24)
            }
            if dates[0] < now, now < dates[1] {
                return true
            }
            
            return false
        }
        return false
    }
}
