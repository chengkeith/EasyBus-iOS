//
//  CityBusNearbyViewController.swift
//  EasyBus
//
//  Created by KL on 29/10/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import UIKit
import CoreLocation

class CityBusNearbyViewController: KLCustomTableViewController, HasEmptyTableView, ButtonRemindViewDelegate {
    
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
    var busViewModels: [CNBusViewModel] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    init() {
        super.init(style: .plain)
    }
    
    deinit {
        print("CityBusNearbyViewController deinit")
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
        
        tableView.register(BusTableViewCell.self)
    }
    
    // MARK: - Init
    
    func searchNearByStops() {
        if let userLocation = UserLocationManager.shared.userLocation?.coordinate, UserSettingManager.shared.isAllowLocation {
            showLoadingOverlay()
            APIManager.shared.getCNBusNearby(lat: userLocation.latitude, long: userLocation.longitude) { (error, buses) in
                if let buses = buses {
                    self.busViewModels = buses.map({ (model) -> CNBusViewModel in
                        return CNBusViewModel(cityBus: model)
                    })
                }
                DispatchQueue.main.async {
                    self.loadingOverlay?.removeFromSuperview()
                    self.showOrRemoveEmptyViewIfNeeded()
                }
            }
        }else {
            busViewModels = []
            showOrRemoveEmptyViewIfNeeded()
        }
    }
    
    func configeEmptyView() {
        noNearbyRemindView.remindTextLabel.text = "我搵唔到附近既車站"
        
        requireLocationRemindView.delegate = self
        requireLocationRemindView.remindTextLabel.text = "要打開咗定位服務先用到呢個功能"
        requireLocationRemindView.remindButton.setTitle("前往設定打開", for: UIControlState())
    }
    
    // MARK: - ButtonRemindViewDelegate
    
    func didClickedRemindViewButton(_ sender: UIButton) {
        tabBarController?.selectedIndex = TabBar.setting.rawValue
    }
    
    // MARK: - Table view data source and delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return busViewModels.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: BusTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        
        let viewModel = busViewModels[indexPath.row]
        cell.descriptionLabel.attributedText = viewModel.direction
        cell.routeNumberLabel.text = viewModel.route
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        navigationController?.pushViewController(CityBusServiceRsultViewController(busViewModel: busViewModels[indexPath.row]), animated: true)
    }
}
