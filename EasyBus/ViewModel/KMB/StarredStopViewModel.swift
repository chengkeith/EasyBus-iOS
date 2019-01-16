//
//  StarredStopViewModel.swift
//  EasyBus
//
//  Created by KL on 14/10/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import UIKit

protocol StarredCellItem {
    var stopAttributedString: NSAttributedString { get }
    var stopEtaAttributedString: NSAttributedString { get }
    var routeString: String { get }
    var etaRemainingMinuteString: String { get }
    static var tagColor: UIColor { get }
}

class StarredStopViewModel: StarredCellItem {
    
    let starredStopModel: StarredStopModel
    var stopAttributedString: NSAttributedString {
        let attributedSentence = NSMutableAttributedString(string: "往", attributes: EtaAttribute.lightGarySmallRegular)

        attributedSentence.append(NSMutableAttributedString(string: starredStopModel.destCName + "\n", attributes: EtaAttribute.darkGrayLargeRegularSemibold))
        attributedSentence.append(NSMutableAttributedString(string: starredStopModel.cName, attributes: EtaAttribute.darkGrayLargeRegularSemibold))
        
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
    var routeString: String {
        if (starredStopModel.serviceType != "1") {
            return starredStopModel.route + "!"
        }else {
            return starredStopModel.route
        }
    }
    var etaRemainingMinute: Int {
        if let eta = etaViewModel?.etas.first {
            if let remainingMinute = etaViewModel?.getRemainingMinute(eta: eta) {
                if (remainingMinute >= -1) {
                    return remainingMinute
                }
            }
        }
        return 999
    }
    var etaRemainingMinuteString: String {
        if let eta = etaViewModel?.etas.first {
            if let remainingMinute = etaViewModel?.getRemainingMinute(eta: eta) {
                if (remainingMinute > 0) {
                    return String(remainingMinute)
                }else {
                    return "0"
                }
            }
        }
        return "-"
    }
    static var tagColor: UIColor {
        return UIColor.rgb(r: 139, g: 0, b: 0)
    }
    static var tagColor2: UIColor {
        return UIColor.rgb(r: 0, g: 100, b: 0)
    }
    var shouldFetchEta = true
    var isFetchingEta = true
    var etaViewModel: EtaViewModel?
    
    init(starredStopModel: StarredStopModel) {
        self.starredStopModel = starredStopModel
    }
}

class AnalyzeStopViewModel: StarredStopViewModel {
    
    let endStopModel: StarredStopModel
    override var stopAttributedString: NSAttributedString {
        let attributedSentence = NSMutableAttributedString(string: "由 ", attributes: EtaAttribute.lightGarySmallRegular)
        attributedSentence.append(NSMutableAttributedString(string: starredStopModel.cName + "\n", attributes: EtaAttribute.darkGrayLargeRegularSemibold))
        attributedSentence.append(NSMutableAttributedString(string: "往 ", attributes: EtaAttribute.lightGarySmallRegular))
        attributedSentence.append(NSMutableAttributedString(string: endStopModel.cName, attributes: EtaAttribute.darkGrayLargeRegularSemibold))
        
        return attributedSentence
    }
    
    init(startStop: StarredStopModel, endStop: StarredStopModel) {
        self.endStopModel = endStop
        super.init(starredStopModel: startStop)
    }
}
