//
//  StopViewModel.swift
//  EasyBus
//
//  Created by KL on 14/10/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import UIKit
import CoreLocation

class StopViewModel: NSObject {
    
    var etas: [EtaModel]?
    var stopData: StopData
    var stopName: String {
        return stopData.cName
    }
    var starButtonTintColor: UIColor {
        if StarredManager.shared.isStarredStop(stop: stopData) {
            return UIColor.rgb(r: 255, g: 0, b: 114)
        }else {
            return .lightGray
        }
    }
    private var isFailToFetchEta = false
    var isFetchingEta = false {
        didSet {
            if isFetchingEta {
                isFailToFetchEta = false
            }else if etas == nil {
                isFailToFetchEta = true
            }
        }
    }
    var fetchingEtaStatusAttributedString: NSAttributedString? {
        if isFetchingEta {
            return NSMutableAttributedString(string: "等待伺服器回應...", attributes: EtaAttribute.regularSemibold)
        }else if isFailToFetchEta {
            return NSMutableAttributedString(string: "無法連接伺服器／系統繁忙\n\n可嘗試更改到站時間服務網址", attributes: EtaAttribute.regularSemibold)
        }else {
            return nil
        }
    }
    var location: CLLocation {
        return CLLocation(latitude: stopData.lat, longitude: stopData.long)
    }
    
    init(stopData: StopData) {
        self.stopData = stopData
    }
    
    func stopNameAttributedString(seq: Int) -> NSAttributedString {
        let attributedSentence = NSMutableAttributedString(string: "\(String(seq)). " + stopData.cName, attributes: EtaAttribute.darkGrayLargeRegularSemibold)
        let newLine = NSMutableAttributedString(string: "\n", attributes: EtaAttribute.regular)
        attributedSentence.append(newLine)
        
        attributedSentence.append(NSMutableAttributedString(string: "車費： $" + String(format: "%g", Double(stopData.airFare) ?? 0), attributes: EtaAttribute.regular))
        
        return attributedSentence
    }
}
