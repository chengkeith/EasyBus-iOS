//
//  StarStyleTableViewController.swift
//  EasyBus
//
//  Created by KL on 21/10/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import UIKit

class StarStyleTableViewController: KLCustomTableViewController {
    
    override init(style: UITableViewStyle = .grouped) {
        super.init(style: style)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var targetIndexPath: IndexPath? {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    var starredViewModels: [StarredStopViewModel] = []
    var reloadTableViewTimer = Timer()
    var refreshEtaFromNetworkTimer = Timer()
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        reloadTableViewTimer.invalidate()
        refreshEtaFromNetworkTimer.invalidate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        startReloadTableViewTimer()
        startRefreshEtaFromNetworkTimer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(StarredEtaTableViewCell.self)
        NotificationCenter.default.addObserver(self, selector: #selector(viewDidBecomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    @objc func viewDidBecomeActive() {
        refreshEtaFromNetwork()
    }
    
    // MARK: - Method
    
    func fetchStopsEta(at indexPath: IndexPath) {
        if !tableView.isEditing {
            print("fetchStopsEta", indexPath)
            let model = starredViewModels[indexPath.row]
            fetchKmbStopEta(model: model)
        }
    }
    
    func fetchKmbStopEta(model: StarredStopViewModel) {
        if !tableView.isEditing {
            if model.shouldFetchEta {
                model.shouldFetchEta = false
                APIManager.shared.getEta(routeStop: model.starredStopModel) { (error, etas) in
                    guard let etas = etas else { return }
                    DispatchQueue.main.async {
                        model.etaViewModel = EtaViewModel(etas: etas)
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    // MARK: - Timer
    
    func startRefreshEtaFromNetworkTimer() {
        refreshEtaFromNetworkTimer.invalidate()
        refreshEtaFromNetworkTimer = Timer.scheduledTimer(timeInterval: UserSettingManager.shared.etaFrequency.timeInterval, target: self, selector: #selector(refreshEtaFromNetwork), userInfo: nil, repeats: true)
    }
    
    func startReloadTableViewTimer() {
        reloadTableViewTimer.invalidate()
        reloadTableViewTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(reloadTableView), userInfo: nil, repeats: true)
    }
    
    @objc func reloadTableView() {
        
        if !tableView.isEditing {
            print("reloadTableView timer")
            tableView.reloadData()
        }
    }
    
    @objc func refreshEtaFromNetwork() {
        print("refreshEtaFromNetwork")
        // set all models to shouldFetchEta
        for model in starredViewModels {
            model.shouldFetchEta = true
        }
        tableView.reloadData()
    }
    
    // MARK: - Table view delegate and datasource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return starredViewModels.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: StarredEtaTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        
        let starredViewModel = starredViewModels[indexPath.row]
        
        cell.colorTagView.backgroundColor = StarredStopViewModel.tagColor
        cell.routeNumberLabel.text = starredViewModel.routeString
        cell.etaLabel.text = starredViewModel.etaRemainingMinuteString
        cell.configEtaView(starredViewModel: starredViewModel, isTarget: indexPath == targetIndexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        startReloadTableViewTimer()
        targetIndexPath = indexPath
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        fetchStopsEta(at: indexPath)
    }
}
