//
//  CNStarredStopViewModel.swift
//  EasyBus
//
//  Created by KL on 30/10/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import UIKit

class CNStarredStopViewModel: StarredCellItem {
    
    let starredStopModel: StarredCNStopModel
    var stopAttributedString: NSAttributedString {
        let attributedSentence = NSMutableAttributedString(string: starredStopModel.routeDescription, attributes: EtaAttribute.lightGarySmallRegular)
        
        attributedSentence.append(NSMutableAttributedString(string: "\n往", attributes: EtaAttribute.lightGarySmallRegular))
        attributedSentence.append(NSMutableAttributedString(string: starredStopModel.destCName + "\n", attributes: EtaAttribute.darkGrayLargeRegularSemibold))
        attributedSentence.append(NSMutableAttributedString(string: starredStopModel.stopName, attributes: EtaAttribute.darkGrayLargeRegularSemibold))
        
        return attributedSentence
    }
    var stopEtaAttributedString: NSAttributedString {
        let newLine = NSMutableAttributedString(string: "\n", attributes: EtaAttribute.smallRegular)
        
        let attributedSentence = NSMutableAttributedString()
        
        attributedSentence.append(stopAttributedString)
        attributedSentence.append(newLine)
        attributedSentence.append(newLine)
        if let etasAttributedString = etaViewModel?.etasAttributedString {
            attributedSentence.append(etasAttributedString)
        }else if isFetchingEta {
            attributedSentence.append(NSMutableAttributedString(string: "等待伺服器回應...", attributes: EtaAttribute.regularSemibold))
        }else {
            attributedSentence.append(NSMutableAttributedString(string: "無法連接伺服器／系統繁忙", attributes: EtaAttribute.regularSemibold))
        }
        return attributedSentence
    }
    var etaRemainingMinuteString: String {
        if let eta = etaViewModel?.etas.first {
            if let remainingMinute = etaViewModel?.getRemainingMinute(timeString: eta.time) {
                if (remainingMinute > 0) {
                    return String(remainingMinute)
                }else {
                    return "0"
                }
            }
        }
        return "-"
    }
    var routeString: String {
        return starredStopModel.route
    }
    static var tagColor: UIColor {
        return UIColor.rgb(r: 0, g: 100, b: 0)
    }
    var shouldFetchEta = true
    var isFetchingEta = true
    var etaViewModel: CNBusEtaViewModel?
    
    init(starredStopModel: StarredCNStopModel) {
        self.starredStopModel = starredStopModel
    }
}
