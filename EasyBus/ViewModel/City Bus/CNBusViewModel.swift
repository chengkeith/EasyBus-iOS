//
//  CNBusViewModel.swift
//  EasyBus
//
//  Created by KL on 27/10/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import Foundation

class CNBusViewModel {
    
    let busData: CNBus
    var route: String {
        return busData.route
    }
    var direction: NSAttributedString {
        let sentence = "往" + busData.destName
        
        let attributedSentence = NSMutableAttributedString(string: sentence, attributes: EtaAttribute.darkGrayLargeRegularSemibold)
        attributedSentence.setAttributes(EtaAttribute.smallRegular, range: NSRange(location: 0, length: 1))
        
        return attributedSentence
    }
    
    var navigationTitle: String {
        return busData.route + " – 往 " + busData.destName
    }
    
    init(cityBus: CNBus) {
        self.busData = cityBus
    }
}
