//
//  FirebaseAnalytics.swift
//  EasyBus
//
//  Created by KL on 17/10/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import Foundation
import Firebase

class FirebaseAnalytics {
    
    static let shared = FirebaseAnalytics()
    
    func logEventWithDeviceId(eventName: String) {
        Analytics.logEvent(eventName, parameters: [
            "device_id": UIDevice.current.identifierForVendor?.uuidString ?? "unkwon"])
    }
    
    func logEvent(eventName: String) {
        Analytics.logEvent(eventName, parameters: nil)
    }
}
