//
//  KMBTrafficNewModel.swift
//  EasyBus
//
//  Created by KL on 5/11/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import Foundation

class KMBTrafficNewsModel: Codable {
    
    let news: [KMBTrafficNews]
    let urlprefix: String
    
    enum CodingKeys: String, CodingKey {
        case urlprefix
        case news = "response"
    }
}

class KMBTrafficNews: Codable {
    let kpiid, kpiReferenceno, kpiTitle, kpiNoticeimageurl: String
    let kpiStartdate, kpiEnddate, kpiEnabled: String
    
    enum CodingKeys: String, CodingKey {
        case kpiid
        case kpiReferenceno = "kpi_referenceno"
        case kpiTitle = "kpi_title"
        case kpiNoticeimageurl = "kpi_noticeimageurl"
        case kpiStartdate = "kpi_startdate"
        case kpiEnddate = "kpi_enddate"
        case kpiEnabled = "kpi_enabled"
    }
}
