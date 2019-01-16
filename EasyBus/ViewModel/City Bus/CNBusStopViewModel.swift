//
//  CNBusStopViewModel.swift
//  EasyBus
//
//  Created by KL on 28/10/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import UIKit

class CNBusStopViewModel {
    
    var etas: [CNBusEtaModel]?
    let stop: CNBusStop
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
            return NSMutableAttributedString(string: "沒有該站信息", attributes: EtaAttribute.regularSemibold)
        }else {
            return nil
        }
    }
    
    init(stop: CNBusStop) {
        self.stop = stop
    }
}

class CNBusEtaViewModel {
    
    var etas: [CNBusEtaModel]
    
    init(etas: [CNBusEtaModel]) {
        self.etas = etas
    }
    
    var etasAttributedString: NSAttributedString {
        let attributedSentence = NSMutableAttributedString(string: "", attributes: EtaAttribute.regular)
        let newLine = NSMutableAttributedString(string: "\n", attributes: EtaAttribute.regular)
        
        guard etas.count > 0 else {
            return NSMutableAttributedString(string: "60 分鐘內不經該站", attributes: EtaAttribute.regularSemibold)
        }
        
        for (i, eta) in etas.enumerated() {
            if i != 0 {
                attributedSentence.append(newLine)
            }
            
            if let displayTimeTips = getRemainingMinute(timeString: eta.time) {
                let displayTimeAttributedString = NSMutableAttributedString(string: String(displayTimeTips) + " 分鐘", attributes: EtaAttribute.regularSemibold)
                attributedSentence.append(displayTimeAttributedString)
                
                if UserSettingManager.shared.showExactTime {
                    let exactTimeAttributedString = NSMutableAttributedString(string: "  " + eta.time, attributes: EtaAttribute.smallRegular)
                    attributedSentence.append(exactTimeAttributedString)
                }
                
                let distanceAttributedString = NSMutableAttributedString(string: "  " + eta.distance, attributes: EtaAttribute.smallRegular)
                attributedSentence.append(distanceAttributedString)
                
                let directionAttributedString = NSMutableAttributedString(string: "  " + eta.direction, attributes: EtaAttribute.smallRegular)
                attributedSentence.append(directionAttributedString)
            }
        }
        return attributedSentence
    }
    
    func getRemainingMinute(timeString: String) -> Int? {
        let spliteTime = timeString.split(separator: ":")
        let now = DateHelper.currentTimeString(dateFormat: "HH:mm").split(separator: ":")
        
        if (spliteTime.count == 2 && now.count == 2) {
            
            guard let aH = Int(String(spliteTime[0])), let aM = Int(String(spliteTime[1])), let nH = Int(String(now[0])), let nM = Int(String(now[1])) else {
                return nil
            }
            
            if nH > aH {
                return ((aH + 24) * 60 + aM) - (nH * 60 + nM)
            }else {
                return (aH * 60 + aM) - (nH * 60 + nM)
            }
            
        }
        return nil
    }
}
