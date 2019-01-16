//
//  TabBarViewController.swift
//  EasyBus
//
//  Created by KL on 12/10/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import UIKit
import Material
import CoreLocation

class TabBarViewController: UITabBarController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        loadViewController()
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch item.tag {
        case TabBar.kmbSearch.rawValue, TabBar.nearBy.rawValue:
            if UserSettingManager.shared.isAllowLocation {
                locationManager.startUpdatingLocation()
            }
        default:
            locationManager.stopUpdatingLocation()
        }
    }
    
    // MARK: - Method
    private func loadViewController() {
        
        var i = 0
        var rootViewControllers: [UIViewController] = []
        
        while let tabBar = TabBar(rawValue: i) {
            let controller = tabBar.rootViewController
            controller.tabBarItem = tabBar.tabBarItem
            controller.tabBarItem.accessibilityLabel = tabBar.accessibilityLabel
            controller.tabBarItem.imageInsets = tabBar.imageInset
            rootViewControllers.append(controller)
            i += 1
        }
        
        viewControllers = rootViewControllers
        selectedIndex = UserSettingManager.shared.appStartTabIndex
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else { return }
        UserLocationManager.shared.userLocation = currentLocation
        print("Current location: \(currentLocation)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    }
}

enum TabBar: Int {
    case nearBy = 0
    case kmbSearch = 1
    case starred = 2
    case smartAnalyze = 3
    case setting = 4
    
    static var array: [TabBar] {
        var tabs: [TabBar] = []
        var i = 0
        while let tab = TabBar(rawValue: i) {
            tabs.append(tab)
            i += 1
        }
        return tabs
    }
    
    var rootViewController: UIViewController {
        switch self {
        case .nearBy:
            return NavigationController(rootViewController: NearbyViewController())
        case .kmbSearch:
            return NavigationController(rootViewController: SearchBusViewController())
        case .setting:
            return NavigationController(rootViewController: SettingViewController())
        case .smartAnalyze:
            return NavigationController(rootViewController: StarredSmartAnalyzeViewController())
        case .starred:
            return NavigationController(rootViewController: StarredViewController())
        }
    }
    
    var tabBarItem: UITabBarItem {
        switch self {
        case .nearBy:
            return UITabBarItem(title: nil, image: Icon.place, tag: self.rawValue)
        case .kmbSearch:
            return UITabBarItem(title: nil, image: Icon.search, tag: self.rawValue)
        case .setting:
            return UITabBarItem(title: nil, image: Icon.settings, tag: self.rawValue)
        case .starred:
            return UITabBarItem(title: nil, image: Icon.cm.star, tag: self.rawValue)
        case .smartAnalyze:
             return UITabBarItem(title: nil, image: #imageLiteral(resourceName: "ic_people"), tag: self.rawValue)
        }
    }
    
    var accessibilityLabel: String {
        switch self {
        case .nearBy:
            return "附近車站"
        case .kmbSearch:
            return "搜尋"
        case .setting:
            return "設定"
        case .starred:
            return "收藏"
        case .smartAnalyze:
            return "智能監測"
        }
    }
    
    var imageInset: UIEdgeInsets {
        return UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
    }
}
