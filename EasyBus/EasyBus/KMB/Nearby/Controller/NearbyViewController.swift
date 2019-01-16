//
//  NearbyViewController.swift
//  EasyBus
//
//  Created by KL on 21/10/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import UIKit
import CoreLocation

class NearbyViewController: StarStyleTableViewController, HasEmptyTableView, ButtonRemindViewDelegate {
    
    let nearByRange: Double = 300
    var emptyView: UIView {
        get {
            if UserSettingManager.shared.isAllowLocation {
                return noNearbyRemindView
            }else {
                return requireLocationRemindView
            }
        }
    }
    let noNearbyRemindView = RemindView()
    let requireLocationRemindView = ButtonRemindView()
    
    init() {
        super.init(style: .plain)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        emptyView.removeFromSuperview()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        searchNearByStops()
        
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "附近車站"
        configeEmptyView()
        showOrRemoveEmptyViewIfNeeded()
    }
    
    // MARK: - Init
    
    func searchNearByStops() {
        let busViewModels = KMBDataManager.shared.busViewModel
        if let userLocation = UserLocationManager.shared.userLocation, UserSettingManager.shared.isAllowLocation {
            starredViewModels = busViewModels.compactMap { (model) -> NearbyStopViewModel? in
                return model.nearestStarredStopViewModel(compareWith: userLocation, in: nearByRange)
                }.sorted(by: { (a, b) -> Bool in
                    if a.busData.specialRoute == "Y" {
                        return false
                    }else if b.busData.specialRoute == "Y" {
                        return true
                    }else {
                        return a.distance < b.distance
                    }
                })
            tableView.reloadData()
            showOrRemoveEmptyViewIfNeeded()
        }else {
            starredViewModels = []
            showOrRemoveEmptyViewIfNeeded()
        }
    }
    
    func configeEmptyView() {
        noNearbyRemindView.remindTextLabel.text = "我搵唔到附近\(String(Int(nearByRange)))米內既車站"
        
        requireLocationRemindView.delegate = self
        requireLocationRemindView.remindTextLabel.text = "要打開咗定位服務先用到呢個功能"
        requireLocationRemindView.remindButton.setTitle("前往設定打開", for: UIControlState())
    }
    
    // MARK: - ButtonRemindViewDelegate
    
    func didClickedRemindViewButton(_ sender: UIButton) {
        tabBarController?.selectedIndex = TabBar.setting.rawValue
    }
}
