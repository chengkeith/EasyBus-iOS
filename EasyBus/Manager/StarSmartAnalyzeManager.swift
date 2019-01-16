//
//  StarSmartAnalyzeManager.swift
//  EasyBus
//
//  Created by KL on 2/12/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import UIKit

class StarSmartAnalyzeManager {
    
    static let shared = StarSmartAnalyzeManager(storingKey: "StarSmartAnalyze")
    private let storingKey: String
    
    private var starredSmartAnalyze: [SmartAnalyzeModel] = []
    var models: [SmartAnalyzeModel] {
        get {
            return starredSmartAnalyze
        }
    }
    
    private init(storingKey: String) {
        self.storingKey = storingKey
        
        NSKeyedArchiver.setClassName("SmartAnalyzeModel", for: SmartAnalyzeModel.self)
        NSKeyedUnarchiver.setClass(SmartAnalyzeModel.self, forClassName: "SmartAnalyzeModel")
        
        if let decodedData  = UserDefaults.standard.data(forKey: storingKey), let models = NSKeyedUnarchiver.unarchiveObject(with: decodedData) as? [SmartAnalyzeModel] {
            self.starredSmartAnalyze = models
        }else {
            self.starredSmartAnalyze = []
        }
        
        // Clear
//        starredSmartAnalyze = []
//        saveStopsToUserDefault()
    }
    
    // MARK: - Append
    
    func append(_ model: SmartAnalyzeModel) {
        if !starredSmartAnalyze.contains(model) {
            starredSmartAnalyze.append(model)
            saveStopsToUserDefault()
        }
    }
    
    // MARK: - deteleStopFromCollection
    
    func deteleStopFromCollection(_ targetModel: SmartAnalyzeModel) {
        starredSmartAnalyze.removeAll { (model) -> Bool in
            return model == targetModel
        }
        saveStopsToUserDefault()
    }
    
    // MARK: - reOrderStops
    
    func reOrderStops(from fromIndex: Int, to toIndex: Int) {
        guard fromIndex < starredSmartAnalyze.count else { return }
        let stopModel = starredSmartAnalyze[fromIndex]
        starredSmartAnalyze.remove(at: fromIndex)
        starredSmartAnalyze.insert(stopModel, at: toIndex)
        saveStopsToUserDefault()
    }
    
    // MARK: - saveStopsToUserDefault
    
    private func saveStopsToUserDefault() {
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: starredSmartAnalyze)
        UserDefaults.standard.set(encodedData, forKey: storingKey)
        UserDefaults.standard.synchronize()
    }
}

