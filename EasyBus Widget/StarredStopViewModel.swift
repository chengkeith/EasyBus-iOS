//
//  StarredStopViewModel.swift
//  EasyBus Widget
//
//  Created by KL on 12/11/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import UIKit

class StarredStopViewModel {
    
    let stopModel: StarredStopModel
    var route: String {
        if stopModel.serviceType != "1" {
            return stopModel.route + "!"
        }else {
            return stopModel.route
        }
    }
    var stopAttributedString: NSAttributedString {
        let attributedSentence = NSMutableAttributedString(string: "往 ", attributes: EtaAttribute.smallRegular)
        
        attributedSentence.append(NSMutableAttributedString(string: stopModel.destCName + "\n", attributes: EtaAttribute.darkGraySmallRegularSemibold))
        attributedSentence.append(NSMutableAttributedString(string: stopModel.cName, attributes: EtaAttribute.darkGraySmallRegularSemibold))
        
        return attributedSentence
    }
    var shouldFetchEta = true
    var etaDisplayString = "..."
    var firstEta: EtaModel? {
        didSet {
            if let eta = firstEta, let arrivalDate = DateHelper.stringToDate(dateString: eta.exactArrivialTime), let remainMins = DateHelper.timeDifferent(from: DateHelper.now, to: arrivalDate)?.minute {
                etaDisplayString = String(remainMins)
                return
            }
            etaDisplayString = "X"
        }
    }
    
    
    init(model: StarredStopModel) {
        self.stopModel = model
    }
}
