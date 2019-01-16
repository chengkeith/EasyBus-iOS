//
//  StarButton.swift
//  EasyBus
//
//  Created by KL on 14/10/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import Material
import UIKit

class StarButton: IconButton {
    
    init() {
        super.init(image: Icon.cm.star, tintColor: .lightGray)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
