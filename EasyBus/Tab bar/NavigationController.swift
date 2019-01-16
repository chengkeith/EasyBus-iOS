//
//  NavigationController.swift
//  EasyBus
//
//  Created by KL on 12/10/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.darkGray, NSAttributedStringKey.font: EasyBusFont.font(type: .heavy, 20)]
        navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.darkGray, NSAttributedStringKey.font: EasyBusFont.font(type: .heavy, 34)]
    }
    
}
