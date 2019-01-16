//
//  SplashViewController.swift
//  EasyBus
//
//  Created by KL on 19/10/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {
    
    let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "app_logo")
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.rgb(r: 126, g: 155, b: 232)
        view.add(logoImageView)
        
        logoImageView.al_height(180)
        logoImageView.al_width(180)
        logoImageView.al_centerXToView()
        logoImageView.al_centerYToView(view, constant: -100)
    }
}


