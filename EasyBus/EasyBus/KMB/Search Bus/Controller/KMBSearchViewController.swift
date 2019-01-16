//
//  SearchBusViewController.swift
//  iOS Practice
//
//  Created by KL on 14/8/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import UIKit

class SearchBusViewController: KLViewController, UITableViewDataSource, UITableViewDelegate, KeyBoardViewDelegate, UISearchBarDelegate {

    let tableView = UITableView(frame: .zero, style: .plain)
    var searchKey: String? = nil
    var header = ""
    let searchController = UISearchController(searchResultsController: nil)
    var busViewModels: [BusViewModel] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    let keyboardView = KeyboardView()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateSearchResult(key: searchController.searchBar.text)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchBar.delegate = self
        searchController.searchBar.isUserInteractionEnabled = true
        searchController.searchBar.setValue("取消", forKey: "_cancelButtonText")
        searchController.searchBar.placeholder = "路線號碼"
        
        searchController.obscuresBackgroundDuringPresentation = false
        definesPresentationContext = true
        
        navigationItem.title = "九巴搜尋"
        navigationItem.searchController = searchController
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.hidesSearchBarWhenScrolling = false
        // Hide back button title in next view controller
        navigationItem.removeBackButtonText()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_notice"), style: .plain, target: self, action: #selector(didTapTrafficNews))
        navigationItem.leftBarButtonItem?.accessibilityLabel = "交通消息"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "城巴", style: .plain, target: self, action: #selector(didTapShowCitybus))
        navigationItem.rightBarButtonItem?.accessibilityLabel = "城巴網頁版"
        
        keyboardView.delegate = self
        initTableView()
    }
    
    // MARK: - Init
    
    func initTableView() {
        safeAreaContentView.add(tableView, keyboardView)
        let views = ["tableView": tableView,
                     "keyboardView": keyboardView]
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "|[tableView]|", options: [], metrics: nil, views: views))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[tableView][keyboardView]|", options: [.alignAllLeft, .alignAllRight], metrics: nil, views: views))
        keyboardView.al_heightEqualToView(tableView)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(BusTableViewCell.self)
    }
    
    // MARK: - Method
    
    private func updateSearchResult(key: String?) {
        busViewModels = KMBDataManager.shared.filteredBusViewModel(key: key)
    }
    
    @objc func didTapShowCitybus() {
        navigationController?.pushViewController(CityBusWebViewController(), animated: true)
    }
    
    @objc func didTapTrafficNews() {
        navigationController?.pushViewController(KMBTrafficNewsController(), animated: true)
    }
    
    func pushStopResultViewController(busViewModel: BusViewModel) {
        if let userLocation = UserLocationManager.shared.userLocation {
            var nearestStopIndex = -1
            for (i, stopViewModel) in busViewModel.stopViewModels.enumerated() {
                let distance = LocationDistanceHelper.distance(loc1: userLocation, loc2: stopViewModel.location)
                
                if (distance < UserSettingManager.shared.nearbyDistance.distance) {
                    if (nearestStopIndex == -1) {
                        nearestStopIndex = i
                    }else {
                        if distance < LocationDistanceHelper.distance(loc1: userLocation, loc2: busViewModel.stopViewModels[nearestStopIndex].location) {
                            nearestStopIndex = i
                        }
                    }
                }
            }
            if (nearestStopIndex != -1) {
                navigationController?.pushViewController(StopResultTableViewController(busViewModel: busViewModel, nearestStopIndex: nearestStopIndex), animated: true)
                return
            }
        }
        navigationController?.pushViewController(StopResultTableViewController(busViewModel: busViewModel), animated: true)
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            updateSearchResult(key: nil)
            resetKeyboard(currentSearchKey: "")
        }
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        return false
    }
    
    // MARK: - Table view data source and delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return busViewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: BusTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        
        let viewModel = busViewModels[indexPath.row]
        cell.descriptionLabel.attributedText = viewModel.direction
        cell.routeNumberLabel.text = viewModel.route
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        pushStopResultViewController(busViewModel: busViewModels[indexPath.row])
        FirebaseAnalytics.shared.logEvent(eventName: "kmb_search")
    }
    
    // MARK: - KeyBoardViewDelegate
    
    func didClickInputButton(key: String) {
        let searchKey = (searchController.searchBar.text ?? "") + key
        searchController.searchBar.text = searchKey
        updateSearchResult(key: searchKey)
        resetKeyboard(currentSearchKey: searchKey)
    }
    
    func didClickDeleteButton() {
        if let searchKey = searchController.searchBar.text, searchKey != "" {
            let newSearchKey = String(searchKey.dropLast())
            searchController.searchBar.text = newSearchKey
            updateSearchResult(key: newSearchKey)
            resetKeyboard(currentSearchKey: newSearchKey)
        }
    }
    
    func didClickCancelButton() {
        searchController.searchBar.text = nil
        updateSearchResult(key: nil)
        resetKeyboard(currentSearchKey: "")
    }
    
    func resetKeyboard(currentSearchKey: String) {
        if currentSearchKey.count == 0 {
            keyboardView.initKeyBoard()
        }else {
            let index = currentSearchKey.count
            let possiblities = busViewModels.compactMap { (model) -> String? in
                let strings = Array(model.busData.route)
                if index < strings.count, strings[index] >= "A" {
                    return String(strings[index])
                }else {
                    return nil
                }
            }
            let sortedKeys = Array(Set(possiblities)).sorted()
            keyboardView.resetLetterKeyboard(letterKeys: sortedKeys)
        }
    }
}
