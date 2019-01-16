//
//  UserLocationManager.swift
//  EasyBus
//
//  Created by KL on 21/10/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import UIKit
import CoreLocation

class UserLocationManager {
    
    static let shared = UserLocationManager()
    var userLocation: CLLocation?
    
    private init() {}
}
