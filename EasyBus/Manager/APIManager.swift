//
//  APIManager.swift
//  EasyBus
//
//  Created by KL on 14/10/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import UIKit

class APIManager {
    
    static let shared = APIManager()
    let baseUrl = "https://service.klhui.hk/api"
    
    func url(_ route: String) -> String {
        return baseUrl + route
    }
    
    func djangoUrl(_ route: String) -> String {
        return "http://me.klhui.hk/easybus" + route
    }
    
    func cnUrl(_ route: String) -> String {
        return baseUrl + route
    }
    
    // MARK: - Admin
    
    func getAppConfig(callback: @escaping (_ error: Error?, _ result: ServerNoticeModel?) -> Void) {
        NetworkManager.decodableGet(url: djangoUrl("/config"), query: nil) { (error, result: ServerNoticeModel?) in
            callback(error, result)
        }
    }
    
    // MARK: - ETA
    
    func testEtaService(url: String, callback: @escaping (_ error: Error?, _ result: EtaResultModel?) -> Void) {
        
        let query: [String: String] = [
            "action": "geteta",
            "lang": "tc",
            "route": "1",
            "bound": "1",
            "stop": "NA06S17500",
            "stop_seq": "16",
            "servicetype": "1"
        ]
        
        NetworkManager.decodableGet(url: url, query: query) { (error, result: EtaResultModel?) in
            callback(error, result)
        }
    }
    
    func getEta(routeStop qeuriableStop: StopQeuriable, callback: @escaping (_ error: Error?, _ result: [EtaModel]?) -> Void) {
        
        let query: [String: String] = [
            "action": "geteta",
            "lang": "tc",
            "route": qeuriableStop.route,
            "bound": qeuriableStop.bound,
            "stop": qeuriableStop.bsiCode.replacingOccurrences(of: "-", with: ""),
            "stop_seq": qeuriableStop.seq,
            "servicetype": qeuriableStop.serviceType
        ]
        
        NetworkManager.decodableGet(url: UserSettingManager.shared.serviceUrl, query: query) { (error, result: EtaResultModel?) in
            callback(error, result?.etas)
        }
    }
    
    // MARK: - KMB Schedule
    
    func getKMBSchedule(bus: BusData, callback: @escaping (_ error: Error?, _ result: [KMBScheduleModel]?) -> Void) {
        
        let query: [String: String] = [
            "action": "getschedule",
            "route": bus.route,
            "bound": String(bus.bound)
        ]
        
        NetworkManager.decodableGet(url: djangoUrl("/schedule"), query: query) { (error, result: KMBScheduleAPIResponse?) in
            callback(error, result?.data["0" + String(bus.serviceType)])
        }
    }
    
    // MARK: - KMB news
    
    func getTrafficNews(callback: @escaping (_ error: Error?, _ result: KMBTrafficNewsModel?) -> Void) {
        
        NetworkManager.decodableGet(url: djangoUrl("/traffic"), query: nil) { (error, result: KMBTrafficNewsModel?) in
            callback(error, result)
        }
    }
    
    // MARK: - User
    
    func registerToken(token: String, callback: ((_ error: Error?, _ result: APIResponse?) -> Void)?) {
        
        let bodyQuery: [String: Any] = [
            "deviceId": UIDevice.current.identifierForVendor?.uuidString ?? "",
            "token": token
        ]
        
        NetworkManager.decodablePost(url: url("/user/registerToken"), bodyQuery: bodyQuery) { (error, result: APIResponse?) in
            callback?(error, result)
        }
    }
    
    func removePush() {
        
        let bodyQuery: [String: Any] = [
            "deviceId": UIDevice.current.identifierForVendor?.uuidString ?? ""
        ]
        
        NetworkManager.decodablePost(url: url("/user/removePush"), bodyQuery: bodyQuery) { (error, result: APIResponse?) in
        }
    }
}

// MARK: - CNBus Bus

extension APIManager {
    
    func getCNBus(callback: @escaping (_ error: Error?, _ result: [CNBus]?) -> Void) {
        NetworkManager.decodableGet(url: cnUrl("/cnbus/getBusList"), query: nil) { (error, result: CNBusListAPIResponse?) in
            callback(error, result?.buses)
        }
    }
    
    func getCNService(bus: CNBus, callback: @escaping (_ error: Error?, _ result: [CNBusService]?) -> Void) {
        let query: [String: String] = [
            "id": bus.id
        ]
        
        NetworkManager.decodableGet(url: cnUrl("/cnbus/getVariant"), query: query) { (error, result: CNBusServiceAPIResponse?) in
            callback(error, result?.service)
        }
    }
    
    func getCNStops(service: CNBusService, callback: @escaping (_ error: Error?, _ result: [CNBusStop]?) -> Void) {
        let query: [String: String] = [
            "qInfo": service.qInfo
        ]
        
        NetworkManager.decodableGet(url: cnUrl("/cnbus/getStops"), query: query) { (error, result: CNBusStopsAPIResponse?) in
            callback(error, result?.stops)
        }
    }
    
    func getCNBusEta(bus: CNBus, service: CNBusService, stop: CNBusStop, callback: @escaping (_ error: Error?, _ result: [CNBusEtaModel]?) -> Void) {
        
        let query: [String: String] = [
            "stopid": stop.stopID,
            "service_no": bus.route,
            "bound": bus.bound,
            "stopseq": stop.stopSeq,
            "rdv": service.rdv
        ]
        
        NetworkManager.decodableGet(url: cnUrl("/cnbus/eta"), query: query) { (error, result: CNBusEtaAPIResponse?) in
            callback(error, result?.response)
        }
    }
    
    func getCNBusEta(starredModel: StarredCNStopModel, callback: @escaping (_ error: Error?, _ result: [CNBusEtaModel]?) -> Void) {
        
        let query: [String: String] = [
            "stopid": starredModel.id,
            "service_no": starredModel.route,
            "bound": starredModel.bound,
            "stopseq": starredModel.seq,
            "rdv": starredModel.rdv
        ]
        
        NetworkManager.decodableGet(url: cnUrl("/cnbus/eta"), query: query) { (error, result: CNBusEtaAPIResponse?) in
            callback(error, result?.response)
        }
    }
    
    func getCNBusNearby(lat: Double, long: Double, callback: @escaping (_ error: Error?, _ result: [CNBus]?) -> Void) {
        
        let query: [String: String] = [
            "lat": String(lat),
            "lon": String(long)
        ]
        
        NetworkManager.decodableGet(url: cnUrl("/cnbus/nearby"), query: query) { (error, result: CNBusNearbyAPIResponse?) in
            callback(error, result?.buses)
        }
    }
    
    func testCNService(urlString: String, callback: @escaping (_ error: Error?, _ result: [CNBus]?) -> Void) {
        
        let query: [String: String] = [
            "lat": String(1),
            "lon": String(1)
        ]
        
        NetworkManager.decodableGet(url: urlString + "/api/cnbus/nearby", query: query) { (error, result: CNBusNearbyAPIResponse?) in
            callback(error, result?.buses)
        }
    }
}
