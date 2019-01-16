//
//  CityBusStopResultViewController.swift
//  EasyBus
//
//  Created by KL on 28/10/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import UIKit
import Material

class CityBusStopResultViewController: KLCustomTableViewController, EtaTableViewCellDelegate {

    let mapView = GoogleMapView()
    let expandMapButton = IconButton(image: #imageLiteral(resourceName: "ic_expand"))
    let userLocationMapButton = IconButton(image: #imageLiteral(resourceName: "ic_user_location"))
    var mapViewHeightConstraint: NSLayoutConstraint?
    
    var stopViewModels: [CNBusStopViewModel] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.scrollToNearest()
            }
        }
    }
    var busService: CNBusService
    var busViewModel: CNBusViewModel
    var targetIndexPath: IndexPath? {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            if let targetIndexPath = targetIndexPath {
                let stopViewModel = stopViewModels[targetIndexPath.row]
                stopViewModel.isFetchingEta = true
                fetchEta(stopViewModel: stopViewModel)
            }
        }
    }
    var reloadTagertCellTimer = Timer()
    var refreshEtaFromNetworkTimer = Timer()

    init(busViewModel: CNBusViewModel, busService: CNBusService) {
        self.busViewModel = busViewModel
        self.busService = busService
        super.init(style: .plain)
    }

    deinit {
        print("CityBusStopResultViewController deinit")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if stopViewModels.isEmpty {
            fetchStops()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        reloadTagertCellTimer.invalidate()
        refreshEtaFromNetworkTimer.invalidate()
        loadingOverlay?.removeFromSuperview()
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_ttb"), style: .plain, target: self, action: #selector(didTapTimeTableButton))

        tableViewSetup()
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
    }

    // MARK: - Method

    func scrollToNearest() {
        if let userLocation = UserLocationManager.shared.userLocation {
            var nearestStopIndex = -1
            for (i, stopViewModel) in stopViewModels.enumerated() {
                let stop = stopViewModel.stop
                let distance = LocationDistanceHelper.distance(loc1: userLocation, lat2: stop.lat, lon2: stop.long)
                
                if (distance < UserSettingManager.shared.nearbyDistance.distance) {
                    if (nearestStopIndex == -1) {
                        nearestStopIndex = i
                    }else {
                        if distance < LocationDistanceHelper.distance(loc1: userLocation, lat2: stopViewModels[nearestStopIndex].stop.lat, lon2: stopViewModels[nearestStopIndex].stop.long) {
                            nearestStopIndex = i
                        }
                    }
                }
            }
            if (nearestStopIndex != -1) {
                targetIndexPath = IndexPath(row: nearestStopIndex, section: 0)
                tableView.scrollToRow(at: IndexPath(row: nearestStopIndex, section: 0), at: .top, animated: true)
            }
        }
        mapView.initPoint(stopViewModels: stopViewModels, targetIndex: targetIndexPath?.row)
    }
    
    func fetchStops() {
        showLoadingOverlay(in: self.safeAreaContentView)
        APIManager.shared.getCNStops(service: busService) { (error, stops) in
            if let stops = stops {
                self.stopViewModels = stops.map({ (stop) -> CNBusStopViewModel in
                    return CNBusStopViewModel(stop: stop)
                })
            }
            DispatchQueue.main.async {
                self.loadingOverlay?.removeFromSuperview()
            }
        }
    }
    
    func fetchEta(stopViewModel: CNBusStopViewModel) {
        APIManager.shared.getCNBusEta(bus: busViewModel.busData, service: busService, stop: stopViewModel.stop) { (error, etaModel) in
            DispatchQueue.main.async {
                stopViewModel.isFetchingEta = false
                if let etaModel = etaModel {
                    stopViewModel.etas = etaModel
                }
                self.tableView.reloadData()
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
        let webViewController = KLWebViewBottomCardViewController(url: "https://service.klhui.hk/api/cnbus/ttb?&rdv=" + busService.rdv + "&bound=" + busViewModel.busData.bound, title: busService.description)
        tabBarController?.present(webViewController, animated: true, completion: nil)
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
        tableView.reloadData()
        let stopViewModel = stopViewModels[indexPath.row]
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
        StarredManager.shared.cnHandleStarStopEvent(controller: self, cnBus: busViewModel.busData, cnService: busService, cnStop: stopViewModels[indexPath.row].stop)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    // MARK: - Table view delegate and datasource

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stopViewModels.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return busService.description
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: EtaTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        let stopViewModel = stopViewModels[indexPath.row]
        let stop = stopViewModel.stop

        weak var weakSelf = self
        cell.delegate = weakSelf
        cell.indexPath = indexPath
        cell.stopNameLabel.text = stop.stopSeq + stop.name
        if StarredManager.shared.isStarredCNStop(cnBus: busViewModel.busData, cnService: busService, cnStop: stopViewModels[indexPath.row].stop) {
            cell.starButton.accessibilityLabel = "取消收藏"
            cell.starButton.tintColor = UIColor.rgb(r: 255, g: 0, b: 114)
        }else {
            cell.starButton.accessibilityLabel = "收藏此站"
            cell.starButton.tintColor = .lightGray
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
