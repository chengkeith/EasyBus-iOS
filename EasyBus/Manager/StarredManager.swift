//
//  StarredManager.swift
//  EasyBus
//
//  Created by KL on 14/10/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import Foundation
import SCLAlertView

class StarredManager {
    
    static let shared = StarredManager(storingKey: "StarredStops", isWidgetDataSource: true)
    static let shared2 = StarredManager(storingKey: "StarredStops2", isWidgetDataSource: false)
    var starredStops: [StarredStopModel]
    var cnStarredStops: [StarredCNStopModel]
    
    var storingKey: String
    var isWidgetDataSource: Bool
    
    private init(storingKey: String, isWidgetDataSource: Bool) {
        self.isWidgetDataSource = isWidgetDataSource
        self.storingKey = storingKey
        
        NSKeyedArchiver.setClassName("StarredStopModel", for: StarredStopModel.self)
        NSKeyedUnarchiver.setClass(StarredStopModel.self, forClassName: "StarredStopModel")
        if let decodedData  = UserDefaults.standard.data(forKey: storingKey), let stops = NSKeyedUnarchiver.unarchiveObject(with: decodedData) as? [StarredStopModel] {
            self.starredStops = stops
        }else {
            self.starredStops = []
        }
        
        // Uncomment the below code to allow using CNStarredStop
//        if let decodedData  = UserDefaults.standard.data(forKey: "CNStarredStop"), let stops = NSKeyedUnarchiver.unarchiveObject(with: decodedData) as? [StarredCNStopModel] {
//            self.cnStarredStops = stops
//        }else {
//            self.cnStarredStops = []
//        }
        self.cnStarredStops = []
        saveStopsToWidgetSuit()
    }
    
    // MARK: - Append
    
    func append(_ starredStopModel: StarredStopModel) {
        if !starredStops.contains(starredStopModel) {
            starredStops.append(starredStopModel)
            saveStopsToUserDefault()
        }
    }
    
    // MARK: - isStarredStop
    
    func isStarredStop(stop rhs: StopData) -> Bool {
        return starredStops.contains(where: { (lhs) -> Bool in
            if (lhs.bound == rhs.bound && lhs.bsiCode == rhs.bsiCode && lhs.seq == rhs.seq && lhs.serviceType == rhs.serviceType && lhs.route == rhs.route) {
                return true
            }else {
                return false
            }
        })
    }
    
    func isStarredCNStop(cnBus: CNBus, cnService: CNBusService ,cnStop: CNBusStop) -> Bool {
        let cnStarredStopModel = StarredCNStopModel(cnBus: cnBus, cnService: cnService, cnStop: cnStop)
        
        return cnStarredStops.contains { $0 == cnStarredStopModel }
    }
    
    // MARK: - saveStopToCollection
    
    private func saveStopToCollection(_ starredStopModel: StarredStopModel) {
        starredStops.append(starredStopModel)
        saveStopsToUserDefault()
    }
    
    private func cnSaveStopToCollection(_ starredStopModel: StarredCNStopModel) {
        cnStarredStops.append(starredStopModel)
        cnSaveStopsToUserDefault()
    }
    
    // MARK: - deteleStopFromCollection
    
    func deteleStopFromCollection(_ starredStopModel: StarredStopModel) {
        starredStops.removeAll { (model) -> Bool in
            return model == starredStopModel
        }
        saveStopsToUserDefault()
    }
    
    func cnDeteleStopFromCollection(_ starredStopModel: StarredCNStopModel) {
        cnStarredStops.removeAll { (model) -> Bool in
            return model == starredStopModel
        }
        cnSaveStopsToUserDefault()
    }
    
    // MARK: - reOrderStops
    
    func reOrderStops(from fromIndex: Int, to toIndex: Int) {
        guard fromIndex < starredStops.count else { return }
        let stopModel = starredStops[fromIndex]
        starredStops.remove(at: fromIndex)
        starredStops.insert(stopModel, at: toIndex)
        saveStopsToUserDefault()
    }
    
    func cnReOrderStops(from fromIndex: Int, to toIndex: Int) {
        guard fromIndex < cnStarredStops.count else { return }
        let stopModel = cnStarredStops[fromIndex]
        cnStarredStops.remove(at: fromIndex)
        cnStarredStops.insert(stopModel, at: toIndex)
        cnSaveStopsToUserDefault()
    }
    
    // MARK: - saveStopsToUserDefault
    
    private func saveStopsToUserDefault() {
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: starredStops)
        UserDefaults.standard.set(encodedData, forKey: storingKey)
        UserDefaults.standard.synchronize()
        saveStopsToWidgetSuit()
    }
    
    private func cnSaveStopsToUserDefault() {
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: cnStarredStops)
        UserDefaults.standard.set(encodedData, forKey: "CNStarredStop")
        UserDefaults.standard.synchronize()
    }
    
    // MARK: - clearAllStarred
    
    private func clearAllStarred() {
        starredStops = []
        saveStopsToUserDefault()
    }
    
    private func cnClearAllStarred() {
        cnStarredStops = []
        saveStopsToUserDefault()
    }
    
    // MARK: - handleStarStopEvent
    
    /// Handle star or cancel stop events. If the stop already starred, delete it. Otherwise, save it.
    ///
    /// - Parameters:
    ///   - busModel: uesd for forming StarredStopModel
    ///   - stopModel: uesd for forming StarredStopModel
    func handleStarStopEvent(controller: UIViewController, busModel: BusData, stopModel: StopData) {
        let starredStopModel = StarredStopModel(busModel: busModel, stopModel: stopModel)
        
        let isExist = starredStops.contains { $0 == starredStopModel }
        
        if isExist {
            deteleStopFromCollection(starredStopModel)
        }else {
            if (starredStops.count > 39) {
                let alert = SCLAlertView()
                alert.showWarning("暫時只支援收藏40個站", subTitle: "", closeButtonTitle: "確定")
                
            }else {
                saveStopToCollection(starredStopModel)
            }
        }
    }
    
    func cnHandleStarStopEvent(controller: UIViewController, cnBus: CNBus, cnService: CNBusService ,cnStop: CNBusStop) {
        let cnStarredStopModel = StarredCNStopModel(cnBus: cnBus, cnService: cnService, cnStop: cnStop)
        
        let isExist = cnStarredStops.contains { $0 == cnStarredStopModel }
        
        if isExist {
            cnDeteleStopFromCollection(cnStarredStopModel)
        }else {
            if (cnStarredStops.count > 19) {
                let alert = SCLAlertView()
                alert.showWarning("暫時只支援收藏20個站", subTitle: "", closeButtonTitle: "確定")
                
            }else {
                cnSaveStopToCollection(cnStarredStopModel)
            }
        }
    }
    
    // MARK: - saveStopsToWidgetSuit
    
    private func saveStopsToWidgetSuit() {
        guard isWidgetDataSource else { return }
        
        if let suite = UserDefaults.init(suiteName: "group.kl.easybus.widget") {
            let encodedData = NSKeyedArchiver.archivedData(withRootObject: starredStops)
            suite.set(encodedData, forKey: "KMBStarredStops")
        }
    }
}
