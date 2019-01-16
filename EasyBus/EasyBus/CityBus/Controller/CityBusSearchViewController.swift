//
//  CityBusSearchViewController.swift
//  EasyBus
//
//  Created by KL on 27/10/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import UIKit
import Material

class CityBusSearchViewController: KLCustomTableViewController, KeyBoardViewDelegate, UISearchBarDelegate, ButtonRemindViewDelegate, HasEmptyTableView {
    
    var emptyView: UIView {
        return noStopRemindView
    }
    let noStopRemindView: ButtonRemindView = {
        let view = ButtonRemindView()
        view.isAccessibilityElement = true
        view.backgroundColor = .white
        view.remindTextLabel.text = "城巴服務暫時停止運作，請嘗試前往網頁版"
        view.remindButton.setTitle("前往網頁版", for: UIControlState())
        return view
    }()
    var searchKey: String? = nil
    var header = ""
    let searchController = UISearchController(searchResultsController: nil)
    var busViewModels: [CNBusViewModel] = []
    var filterBusViewModels: [CNBusViewModel] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    let keyboardView = KeyboardView()
    
    init() {
        super.init(style: .plain)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        emptyView.removeFromSuperview()
        self.loadingOverlay?.removeFromSuperview()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        if busViewModels.isEmpty {
//            fetchStopList()
//        }
        showOrRemoveEmptyViewIfNeeded()
        updateSearchResult(key: searchController.searchBar.text)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        noStopRemindView.delegate = self
        
        searchController.searchBar.delegate = self
        searchController.searchBar.setValue("取消", forKey: "_cancelButtonText")
        searchController.searchBar.placeholder = "路線號碼"
        
        searchController.obscuresBackgroundDuringPresentation = false
        definesPresentationContext = true
        
        navigationItem.title = "城巴/新巴搜尋"
        navigationItem.searchController = searchController
        navigationItem.largeTitleDisplayMode = .never
//        navigationItem.rightBarButtonItem = UIBarButtonItem(image: Icon.place, style: .plain, target: self, action: #selector(didTapNearbyButton))
        navigationItem.hidesSearchBarWhenScrolling = false
        // Hide back button title in next view controller
        navigationItem.removeBackButtonText()
        
        keyboardView.delegate = self
    }

    // MARK: - Init
    
    override func setUpAutoLayout() {
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
    
    @objc func didTapNearbyButton() {
        navigationController?.pushViewController(CityBusNearbyViewController(), animated: true)
    }
    
    private func fetchStopList() {
        showLoadingOverlay(in: self.safeAreaContentView)
        APIManager.shared.getCNBus { (error, buses) in
            if let buses = buses {
                self.busViewModels = buses.map({ (model) -> CNBusViewModel in
                    return CNBusViewModel(cityBus: model)
                })
            }else {
                DispatchQueue.main.async {
                    self.showOrRemoveEmptyViewIfNeeded()
                }
            }
            DispatchQueue.main.async {
                self.updateSearchResult(key: nil)
                self.loadingOverlay?.removeFromSuperview()
            }
        }
    }
    
    private func updateSearchResult(key: String?) {
        if let key = key, key != "" {
            filterBusViewModels = busViewModels.filter({ (viewModel) -> Bool in
                return viewModel.busData.route.contains(key.uppercased())
            }).sorted { (a, b) -> Bool in
                let aHasPrefix = a.busData.route.hasPrefix(key.uppercased())
                let bHasPrefix = b.busData.route.hasPrefix(key.uppercased())
                
                if (aHasPrefix && bHasPrefix) {
                    if (a.busData.route != b.busData.route) {
                        return a.busData.route < b.busData.route
                    }
                }
                
                return aHasPrefix
            }
        }else {
            filterBusViewModels = busViewModels
        }
        
        resetKeyboard(currentSearchKey: key ?? "")
    }
    
    // MARK: - ButtonRemindViewDelegate
    
    func didClickedRemindViewButton(_ sender: UIButton) {
        navigationController?.pushViewController(CityBusWebViewController(), animated: true)
    }
    
    // MARK: - Table view data source and delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterBusViewModels.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: BusTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        
        let viewModel = filterBusViewModels[indexPath.row]
        cell.descriptionLabel.attributedText = viewModel.direction
        cell.routeNumberLabel.text = viewModel.route
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        navigationController?.pushViewController(CityBusServiceRsultViewController(busViewModel: filterBusViewModels[indexPath.row]), animated: true)
        FirebaseAnalytics.shared.logEvent(eventName: "cnbus_search")
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            updateSearchResult(key: nil)
        }
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        return false
    }
    
    // MARK: - KeyBoardViewDelegate
    
    func didClickInputButton(key: String) {
        let searchKey = (searchController.searchBar.text ?? "") + key
        searchController.searchBar.text = searchKey
        updateSearchResult(key: searchKey)
    }
    
    func didClickDeleteButton() {
        if let searchKey = searchController.searchBar.text, searchKey != "" {
            let newSearchKey = String(searchKey.dropLast())
            searchController.searchBar.text = newSearchKey
            updateSearchResult(key: newSearchKey)
        }
    }
    
    func didClickCancelButton() {
        searchController.searchBar.text = nil
        updateSearchResult(key: nil)
    }
    
    func resetKeyboard(currentSearchKey: String) {
        let index = currentSearchKey.count
        let possiblities = filterBusViewModels.compactMap { (model) -> String? in
            let strings = Array(model.busData.route)
            if index < strings.count, strings[index] >= "A" {
                return String(strings[index])
            }else {
                return nil
            }
        }
        
        let sortedKeys = Array(Set(possiblities)).sorted()
        DispatchQueue.main.async {
            self.keyboardView.resetLetterKeyboard(letterKeys: sortedKeys)
        }
    }
}
