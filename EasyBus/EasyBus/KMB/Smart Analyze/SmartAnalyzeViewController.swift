//
//  SmartAnalyzeViewController.swift
//  EasyBus
//
//  Created by KL on 20/11/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import UIKit
import SCLAlertView

class SmartAnalyzeViewController: StarStyleTableViewController {
    
    enum Section: String {
        case info = "基本資料"
        case option = "選擇"
        case name = "收藏名稱"
    }
    
    private var analyzedStopViewModels: [AnalyzeStopViewModel] = []
    private var sortedStopViewModels: [AnalyzeStopViewModel] = []
    
    private var startStop: StopData?
    private var endStop: StopData?
    private var starModel: SmartAnalyzeModel?
    
    
    var sections: [Section] = [.info, .option]
    
    init(startStop: StopData, endStop: StopData) {
        self.startStop = startStop
        self.endStop = endStop
        super.init(style: .grouped)
        sections = [.info, .option]
    }
    
    init(starModel: SmartAnalyzeModel) {
        self.starModel = starModel
        super.init(style: .grouped)
        sections = [.name, .option]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "智能監測"
        if starModel == nil {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "收藏", style: .plain, target: self, action: #selector(didTapSaveAnalyze))
        }
        
        guard analyzedStopViewModels.count == 0 else { return }
        if let startStop = startStop, let endStop = endStop {
            analyzedStopViewModels = KMBHelper.shared.getNearbyBusStop(fromLat: startStop.lat, fromLong: startStop.long, toLat: endStop.lat, toLong: endStop.long)
        }else if let starModel = starModel {
            analyzedStopViewModels = KMBHelper.shared.getNearbyBusStop(fromLat: starModel.startLat, fromLong: starModel.startLong, toLat: starModel.endLat, toLong: starModel.endLong)
        }
        fetchAllStopEta()
    }
    
    private func sortFastestEta() {
        sortedStopViewModels = analyzedStopViewModels.sorted(by: { (lhs, rhs) -> Bool in
            return lhs.etaRemainingMinute < rhs.etaRemainingMinute
        })
    }
    
    override func reloadTableView() {
        sortFastestEta()
        super.reloadTableView()
    }
    
    @objc func didTapSaveAnalyze() {
        guard let startStop = startStop, let endStop = endStop else { return }
        
        let alert = SCLAlertView()
        let dafultName = startStop.cName + " ----> " + endStop.cName
        let textField = alert.addTextField("預設名稱")
        
        alert.addButton("新增", action: {
            if let customName = textField.text {
                StarSmartAnalyzeManager.shared.append(SmartAnalyzeModel(name: customName, startStop: startStop, endStop: endStop))
            }else {
                StarSmartAnalyzeManager.shared.append(SmartAnalyzeModel(name: dafultName, startStop: startStop, endStop: endStop))
            }
        })
        alert.addButton("使用預設", action: {
            StarSmartAnalyzeManager.shared.append(SmartAnalyzeModel(name: dafultName, startStop: startStop, endStop: endStop))
        })
        alert.showEdit("收藏智能監測", subTitle: "請輸入自訂名稱，或選擇預設名稱", closeButtonTitle: "取消")
    }
    
    @objc override func refreshEtaFromNetwork() {
        print("refreshEtaFromNetwork")
        // set all models to shouldFetchEta
        for model in analyzedStopViewModels {
            model.shouldFetchEta = true
        }
        fetchAllStopEta()
        tableView.reloadData()
    }
    
    override func fetchStopsEta(at indexPath: IndexPath) {
    }
    
    func fetchAllStopEta() {
        analyzedStopViewModels.forEach { (model) in
            if !tableView.isEditing {
                if model.shouldFetchEta {
                    model.shouldFetchEta = false
                    APIManager.shared.getEta(routeStop: model.starredStopModel) { (error, etas) in
                        guard let etas = etas else { return }
                        DispatchQueue.main.async {
                            model.etaViewModel = EtaViewModel(etas: etas)
                            self.sortFastestEta()
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - table view datasource and delegate
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sections[section] {
        case .name:
            return 1
        case .info:
            return 2
        case .option:
            return sortedStopViewModels.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        switch section {
        case .name:
            let cell = UITableViewCell()
            cell.textLabel?.numberOfLines = 0
            cell.selectionStyle = .none
            cell.textLabel?.font = EasyBusFont.font(type: .regular, 15)
            cell.textLabel?.textColor = .darkGray
            cell.separatorInset = UIEdgeInsetsMake(0, 16, 0, 16)
            cell.textLabel?.text = starModel?.name
            
            return cell
        case .info:
            let cell = UITableViewCell()
            cell.textLabel?.numberOfLines = 0
            cell.selectionStyle = .none
            cell.textLabel?.font = EasyBusFont.font(type: .regular, 15)
            cell.textLabel?.textColor = .darkGray
            cell.separatorInset = UIEdgeInsetsMake(0, 16, 0, 16)
            
            if let startStop = startStop, let endStop = endStop {
                if indexPath.row == 0 {
                    cell.textLabel?.text = "由: " + startStop.cName
                }else if indexPath.row == 1 {
                    cell.textLabel?.text = "往: " + endStop.cName
                }
            }
            
            return cell
        case .option:
            let cell: StarredEtaTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            
            let starredViewModel = sortedStopViewModels[indexPath.row]
            
            cell.colorTagView.backgroundColor = StarredStopViewModel.tagColor
            cell.routeNumberLabel.text = starredViewModel.routeString
            cell.etaLabel.text = starredViewModel.etaRemainingMinuteString
            cell.configEtaView(starredViewModel: starredViewModel, isTarget: indexPath == targetIndexPath)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].rawValue
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    }
}
