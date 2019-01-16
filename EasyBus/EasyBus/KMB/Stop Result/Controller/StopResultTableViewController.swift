//
//  StopResultTableViewController.swift
//  EasyBus
//
//  Created by KL on 14/10/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import UIKit
import Material

class StopResultTableViewController: KLCustomTableViewController, EtaTableViewCellDelegate {
    
    let mapView = GoogleMapView()
    let expandMapButton = IconButton(image: #imageLiteral(resourceName: "ic_expand"))
    let userLocationMapButton = IconButton(image: #imageLiteral(resourceName: "ic_user_location"))
    var mapViewHeightConstraint: NSLayoutConstraint?
    
    var busViewModel: BusViewModel
    var targetIndexPath: IndexPath? {
        willSet {
            if let newValue = newValue {
                let stopViewModel = busViewModel.stopViewModels[newValue.row]
                stopViewModel.isFetchingEta = true
                DispatchQueue.main.async {
                    self.tableView.reloadRows(at: [newValue], with: .automatic)
                }
                fetchEta(stopViewModel: stopViewModel)
            }
        }
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    var nearestStopIndex: Int?
    var reloadTagertCellTimer = Timer()
    var refreshEtaFromNetworkTimer = Timer()
    
    init(busViewModel: BusViewModel, nearestStopIndex: Int? = nil) {
        self.busViewModel = busViewModel
        self.nearestStopIndex = nearestStopIndex
        super.init(style: .plain)
    }
    
    deinit {
        print("StopResult deinit")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        reloadTagertCellTimer.invalidate()
        refreshEtaFromNetworkTimer.invalidate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        tableView.reloadData()
        startReloadTagertCellTimer()
        startRefreshEtaFromNetworkTimer()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = busViewModel.navigationTitle
        navigationItem.removeBackButtonText()
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(image: Icon.visibility, style: .plain, target: self, action: #selector(didTapAnalyzeButton)), UIBarButtonItem(image: #imageLiteral(resourceName: "ic_ttb"), style: .plain, target: self, action: #selector(didTapTimeTableButton))]
        
        tableViewSetup()
        mapView.initPoint(stopViewModels: busViewModel.stopViewModels, targetIndex: targetIndexPath?.row)
    }
    
    override func setUpAutoLayout() {
        safeAreaContentView.add(mapView, tableView)
        
        let views = ["mapView": mapView,
                     "tableView": tableView]
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[mapView][tableView]|", options: [.alignAllLeft, .alignAllRight], metrics: nil, views: views))
        tableView.al_fillSuperViewHorizontally()
        mapViewHeightConstraint = mapView.heightAnchor.constraint(equalToConstant: 300)
        mapViewHeightConstraint?.isActive = true
        
        mapView.add(expandMapButton, userLocationMapButton)
        userLocationMapButton.addTarget(self, action: #selector(userLocationMapButtonOnClicked), for: .touchUpInside)
        userLocationMapButton.al_height(44)
        userLocationMapButton.al_width(44)
        userLocationMapButton.al_topToView(mapView, distance: 8, alignToSafeArea: false)
        userLocationMapButton.al_rightToView(mapView, distance: -16)
        
        expandMapButton.addTarget(self, action: #selector(expandMapButtonOnClicked), for: .touchUpInside)
        expandMapButton.al_height(44)
        expandMapButton.al_width(44)
        expandMapButton.al_bottomToView(mapView, distance: -8, alignToSafeArea: false)
        expandMapButton.al_rightToView(mapView, distance: -16)
        repositionMap(toReduce: false)
    }
    
    // MARK: - Init
    
    func tableViewSetup() {
        tableView.register(EtaTableViewCell.self)
        if let nearestStopIndex = nearestStopIndex {
            let indexPath = IndexPath(row: nearestStopIndex, section: 0)
            tableView.beginUpdates()
            tableView.scrollToRow(at: indexPath, at: .top, animated: false)
            tableView.endUpdates()
            targetIndexPath = indexPath
        }
    }
    
    // MARK: - Method
    
    @objc func didTapAnalyzeButton() {
        if let targetIndexPath = targetIndexPath {
            let stopViewModel = busViewModel.stopViewModels[targetIndexPath.row]
            let startingStop = stopViewModel.stopData
            let destinationOption = busViewModel.stopViewModels[targetIndexPath.row + 1..<busViewModel.stopViewModels.count].map { (model) -> String in
                return model.stopName
            }
            
            let pickerController = KLPickerViewController.init(items: destinationOption) { (i) in
                let destIndex = targetIndexPath.row + 1 + i
                guard destIndex < self.busViewModel.stopViewModels.count else { return }
                let destionationStop = self.busViewModel.stopViewModels[destIndex].stopData
                self.navigationController?.pushViewController(SmartAnalyzeViewController(startStop: startingStop, endStop: destionationStop), animated: true)
            }
            pickerController.navigationItem.title = "選擇目的地"
            tabBarController?.present(pickerController, animated: true, completion: nil)
        }else {
            if let window = UIApplication.shared.keyWindow {
                KLAlertViewManager.init().showTopAlert(target: window, contentInset: UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0), text: "請先選擇一個車站")
            }
        }
    }
    
    func fetchEta(stopViewModel: StopViewModel) {
        APIManager.shared.getEta(routeStop: stopViewModel.stopData) { (error, etaModel) in
            DispatchQueue.main.async {
                stopViewModel.isFetchingEta = false
                if let etaModel = etaModel {
                    stopViewModel.etas = etaModel
                }
                if let targetIndexPath = self.targetIndexPath {
                    self.tableView.reloadRows(at: [targetIndexPath], with: .automatic)
                }
            }
        }
    }
    
    func repositionMap(toReduce: Bool) {
        if toReduce {
            mapViewHeightConstraint?.constant = ScreenSizeManager.screenHeight / 4
            expandMapButton.isHidden = false
        }else {
            mapViewHeightConstraint?.constant = ScreenSizeManager.screenHeight / 2
            expandMapButton.isHidden = true
        }
    }
    
    func startReloadTagertCellTimer() {
        reloadTagertCellTimer.invalidate()
        reloadTagertCellTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(reloadTagertCell), userInfo: nil, repeats: true)
    }
    
    func startRefreshEtaFromNetworkTimer() {
        refreshEtaFromNetworkTimer.invalidate()
        refreshEtaFromNetworkTimer = Timer.scheduledTimer(timeInterval: UserSettingManager.shared.etaFrequency.timeInterval, target: self, selector: #selector(refreshEtaFromNetwork), userInfo: nil, repeats: true)
    }
    
    @objc func didTapTimeTableButton() {
        let timeTableController = TimeTableTableViewController(bus: busViewModel.busData)
        timeTableController.customConfig(navTitle: "時間表", doneTitle: "關閉")
        tabBarController?.present(timeTableController, animated: true, completion: nil)
    }
    
    @objc func reloadTagertCell() {
        print("reloadTagertCell")
        guard let indexPath = targetIndexPath else {
            return
        }
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    @objc func refreshEtaFromNetwork() {
        guard let indexPath = targetIndexPath else {
            return
        }
        print("refreshEtaFromNetwork")
        tableView.reloadRows(at: [indexPath], with: .automatic)
        let stopViewModel = busViewModel.stopViewModels[indexPath.row]
        fetchEta(stopViewModel: stopViewModel)
    }
    
    @objc func expandMapButtonOnClicked() {
        repositionMap(toReduce: false)
    }
    
    @objc func userLocationMapButtonOnClicked() {
        mapView.scrollToUserLocation()
    }
    
    // MARK: - EtaTableViewCellDelegate
    
    func starredButtonOnClicked(for indexPath: IndexPath) {
        StarredManager.shared.handleStarStopEvent(controller: self, busModel: busViewModel.busData, stopModel: busViewModel.stopViewModels[indexPath.row].stopData)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    // MARK: - Table view delegate and datasource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return busViewModel.stopViewModels.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: EtaTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        
        let stopViewModel = busViewModel.stopViewModels[indexPath.row]
        
        weak var weakSelf = self
        cell.delegate = weakSelf
        cell.indexPath = indexPath
        cell.stopNameLabel.attributedText = stopViewModel.stopNameAttributedString(seq: indexPath.row + 1)
        cell.starButton.tintColor = stopViewModel.starButtonTintColor
        if StarredManager.shared.isStarredStop(stop: stopViewModel.stopData) {
            cell.starButton.accessibilityLabel = "取消收藏"
        }else {
            cell.starButton.accessibilityLabel = "收藏此站"
        }
        
        cell.configEtaView(stopViewModel: stopViewModel, isTarget: indexPath == targetIndexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        startRefreshEtaFromNetworkTimer()
        targetIndexPath = indexPath
        mapView.setSelectMarker(index: indexPath.row)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        repositionMap(toReduce: true)
    }
}
