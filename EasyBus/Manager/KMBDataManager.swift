//
//  KMBDataManager.swift
//  EasyBus
//
//  Created by KL on 12/10/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import UIKit

/// a helper that loads all data from kmbData.json
class KMBDataManager {
    
    static let shared = KMBDataManager()
    var busViewModel: [BusViewModel] = []
    var keyboards: [[String]] = []
    var version = -1
    
    init() {
        print("init kmb manager")
        initData(willloadToCoreData: false)
    }
    
    func filteredBusViewModel(key: String?) -> [BusViewModel] {
        if let key = key, key != "" {
            return busViewModel.filter({ (viewModel) -> Bool in
                return viewModel.busData.route.contains(key.uppercased())
            }).sorted { (a, b) -> Bool in
                let aHasPrefix = a.busData.route.hasPrefix(key.uppercased())
                let bHasPrefix = b.busData.route.hasPrefix(key.uppercased())

                if (aHasPrefix && bHasPrefix) {
                    if (a.busData.route != b.busData.route) {
                        return a.busData.route < b.busData.route
                    }
                    return a.busData.serviceType < b.busData.serviceType
                }
                
                return aHasPrefix
            }
        }else {
            return busViewModel
        }
    }
    
    func initData(willloadToCoreData: Bool) {
        do {
            try initFromDisk()
        } catch KmbDataError.initFromDiskFail {
            print("fail to init from disk, trying to init from bundle")
            do {
                try initDataFromBundle()
            } catch {
                print("fail to init from bundle")
            }
        } catch {
            print("Unexpected error: \(error). Trying to init from bundle")
            do {
                try initDataFromBundle()
            } catch {
                print("fail to init from bundle")
            }
        }
    }
    
    func initFromDisk() throws {
        do {
            if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileURL = documentDirectory.appendingPathComponent("kmbData.json")
                let data = try Data(contentsOf: fileURL, options: .mappedIfSafe)
                let decodedResult = try JSONDecoder().decode(KMBResultModel.self, from: data)
                print("successfully init from disk")
                busViewModel = decodedResult.result.map({ (busData) -> BusViewModel in
                    return BusViewModel(busData: busData)
                }).sorted { (a, b) -> Bool in
                    if (a.busData.route != b.busData.route) {
                        return a.busData.route < b.busData.route
                    }
                    return a.busData.serviceType < b.busData.serviceType
                }
                keyboards = decodedResult.keyboards
                version = decodedResult.version
            }
        } catch {
            throw KmbDataError.initFromDiskFail
        }
    }
    
    func initDataFromBundle() throws {
        if let path = Bundle.main.path(forResource: "kmbData", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let decodedResult = try JSONDecoder().decode(KMBResultModel.self, from: data)
                print("successfully init from Bundle")
                busViewModel = decodedResult.result.map({ (busData) -> BusViewModel in
                    return BusViewModel(busData: busData)
                }).sorted { (a, b) -> Bool in
                    if (a.busData.route != b.busData.route) {
                        return a.busData.route < b.busData.route
                    }
                    return a.busData.serviceType < b.busData.serviceType
                }
                keyboards = decodedResult.keyboards
                version = decodedResult.version
            } catch {
                throw KmbDataError.dataNotFoundOrDecodeFail
            }
        }else {
            throw KmbDataError.bundlePathNotFound
        }
    }
}

enum KmbDataError: Error {
    case bundlePathNotFound
    case dataNotFoundOrDecodeFail
    case initFromDiskFail
}
