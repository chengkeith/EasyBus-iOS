//
//  CityBusStarredViewController.swift
//  EasyBus
//
//  Created by KL on 29/10/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import UIKit

class CityBusStarredViewController: KLCustomTableViewController, HasEmptyTableView, ButtonRemindViewDelegate {
    
    var emptyView: UIView {
        return noStarredRemindView
    }
    let noStarredRemindView = ButtonRemindView()
    let editBarButton = UIBarButtonItem(title: "編輯", style: .plain, target: nil, action: nil)
    var isEditingTableView: Bool = false {
        didSet {
            if isEditingTableView {
                DispatchQueue.main.async {
                    self.tableView.setEditing(true, animated: false)
                }
                editBarButton.title = "完成"
            }else {
                DispatchQueue.main.async {
                    self.tableView.setEditing(false, animated: false)
                }
                editBarButton.title = "編輯"
            }
        }
    }
    var targetIndexPath: IndexPath? {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    var starredViewModels: [CNStarredStopViewModel] = [] {
        didSet {
            if !tableView.isEditing {
                self.tableView.reloadData()
            }
        }
    }
    var reloadTableViewTimer = Timer()
    var refreshEtaFromNetworkTimer = Timer()
    
    init() {
        super.init(style: .plain)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        reloadTableViewTimer.invalidate()
        refreshEtaFromNetworkTimer.invalidate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        startReloadTableViewTimer()
        startRefreshEtaFromNetworkTimer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        starredViewModels = StarredManager.shared.cnStarredStops.map { (model) -> CNStarredStopViewModel in
            return CNStarredStopViewModel(starredStopModel: model)
        }
        tableView.reloadData()
        showOrRemoveEmptyViewIfNeeded()
        super.viewWillAppear(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.rightBarButtonItem = editBarButton
        editBarButton.target = self
        editBarButton.action = #selector(didClickedEditBarButton)
        title = "城巴／新巴收藏"
        
        tableView.register(StarredEtaTableViewCell.self)
        
        noStarredRemindView.delegate = self
        noStarredRemindView.remindTextLabel.text = "你未收藏任何車站喎"
        noStarredRemindView.remindButton.setTitle("搜尋車站", for: UIControlState())
    }
    
    // MARK: - Method
    
    func fetchStopsEta(at indexPath: IndexPath) {
        if !tableView.isEditing {
            let viewModel = starredViewModels[indexPath.row]
            let model = viewModel.starredStopModel
            if viewModel.shouldFetchEta {
                viewModel.shouldFetchEta = false
                APIManager.shared.getCNBusEta(starredModel: model) { (error, etas) in
                    print("get from network", indexPath)
                    guard let etas = etas else { return }
                    DispatchQueue.main.async {
                        viewModel.etaViewModel = CNBusEtaViewModel(etas: etas)
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
        reloadTableViewTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(reloadTableView), userInfo: nil, repeats: true)
    }
    
    @objc func didClickedEditBarButton() {
        targetIndexPath = nil
        isEditingTableView = !isEditingTableView
    }
    
    @objc func reloadTableView() {
        print("reloadTableView timer")
        if !tableView.isEditing {
            tableView.reloadData()
        }
    }
    
    @objc func refreshEtaFromNetwork() {
        print("refreshEtaFromNetwork timer")
        // set all models to shouldFetchEta
        for model in starredViewModels {
            model.shouldFetchEta = true
            tableView.reloadData()
        }
    }
    
    // MARK: - ButtonRemindViewDelegate
    
    func didClickedRemindViewButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
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
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            StarredManager.shared.cnDeteleStopFromCollection(starredViewModels[indexPath.row].starredStopModel)
            tableView.beginUpdates()
            starredViewModels.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "移除"
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedObject = starredViewModels[sourceIndexPath.row]
        StarredManager.shared.cnReOrderStops(from: sourceIndexPath.row, to: destinationIndexPath.row)
        starredViewModels.remove(at: sourceIndexPath.row)
        starredViewModels.insert(movedObject, at: destinationIndexPath.row)
    }
}
