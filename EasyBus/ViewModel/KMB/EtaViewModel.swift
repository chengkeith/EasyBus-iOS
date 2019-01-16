//
//  EtaViewModel.swift
//  EasyBus
//
//  Created by KL on 14/10/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import UIKit

class EtaViewModel: NSObject {
    
    var etas: [EtaModel]
    var etasAttributedString: NSAttributedString {
        let attributedSentence = NSMutableAttributedString(string: "", attributes: EtaAttribute.regular)
        let newLine = NSMutableAttributedString(string: "\n", attributes: EtaAttribute.regular)
        
        for (i, eta) in etas.enumerated() {
            if (eta.w != nil) {
                if i != 0 {
                    attributedSentence.append(newLine)
                }
                
                if let displayTimeTips = getRemainingTimeString(eta: eta) {
                    let displayTimeAttributedString = NSMutableAttributedString(string: displayTimeTips, attributes: EtaAttribute.regularSemibold)
                    attributedSentence.append(displayTimeAttributedString)
                    
                    if UserSettingManager.shared.showExactTime {
                        let exactTimeAttributedString = NSMutableAttributedString(string: "  " + eta.exactArrivialTime, attributes: EtaAttribute.smallRegular)
                        attributedSentence.append(exactTimeAttributedString)
                    }
                }else {
                    let displayTimeAttributedString = NSMutableAttributedString(string: eta.displayTime, attributes: EtaAttribute.regularSemibold)
                    attributedSentence.append(displayTimeAttributedString)
                }
            }else {
                attributedSentence.append(newLine)
                let displayTimeAttributedString = NSMutableAttributedString(string: eta.displayTime, attributes: EtaAttribute.redRegularSemibold)
                attributedSentence.append(displayTimeAttributedString)
            }
            
        }
        return attributedSentence
    }
    
    init(etas: [EtaModel]) {
        self.etas = etas
    }
    
    func getRemainingMinute(eta: EtaModel) -> Int? {
        let splitedDisplayTime = eta.displayTime.split(separator: "　")
        if splitedDisplayTime.count > 0 {
            let spliteTime = splitedDisplayTime[0].split(separator: ":")
            let now = DateHelper.currentTimeString(dateFormat: "HH:mm").split(separator: ":")
            
            if (spliteTime.count == 2 && now.count == 2) {
                
                guard let aH = Int(String(spliteTime[0])), let aM = Int(String(spliteTime[1])), let nH = Int(String(now[0])), let nM = Int(String(now[1])) else {
                    return nil
                }
                
                let spliteExactTime = eta.exactArrivialTime.split(separator: " ")
                if spliteExactTime.count > 0, let arrivalDate = DateHelper.stringToDate(dateFormat: "yyyy-MM-dd", dateString: String(spliteExactTime[0])) {
                    if arrivalDate > DateHelper.now {
                        let difference = ((aH + 24) * 60 + aM) - (nH * 60 + nM)
                        if difference < 200 {
                            return difference
                        }
                    }
                }
                
                return (aH * 60 + aM) - (nH * 60 + nM)
            }
        }
        return nil
    }
    
    func getRemainingTimeString(eta: EtaModel) -> String? {
        if let remainingMinute = getRemainingMinute(eta: eta) {
            if (remainingMinute <= 0) {
                return "快將到達或已離開"
            }
            let spliteExactTime = eta.displayTime.split(separator: "　")
            if spliteExactTime.count > 1 {
                return "\(remainingMinute) 分鐘  " + spliteExactTime[1]
            }
            return "\(remainingMinute) 分鐘"
        }else {
            return nil
        }
    }
}
