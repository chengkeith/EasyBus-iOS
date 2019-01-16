//
//  CityBusServiceRsultViewController.swift
//  EasyBus
//
//  Created by KL on 28/10/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import UIKit

class CityBusServiceRsultViewController: KLCustomTableViewController {
    
    enum Section {
        case normal
        case notwork
        case tips
    }
    
    var sections: [Section] = [.normal, .notwork, .tips]
    
    unowned var busViewModel: CNBusViewModel
    var serviceG: [CNBusService] = []
    var serviceR: [CNBusService] = []
    
    init(busViewModel: CNBusViewModel) {
        self.busViewModel = busViewModel
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("CityBusServiceRsultViewController deinit")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if serviceG.isEmpty, serviceR.isEmpty {
            fetchService()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        loadingOverlay?.removeFromSuperview()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "\(busViewModel.route) - 往\(busViewModel.busData.destName)"
        navigationItem.removeBackButtonText()
        
        tableView.register(ServiceTableViewCell.self)
    }
    
    private func fetchService() {
        showLoadingOverlay(in: self.safeAreaContentView)
        APIManager.shared.getCNService(bus: busViewModel.busData) { (error, services) in
            if let services = services {
                for service in services {
                    if service.color == "G" {
                        self.serviceG.append(service)
                    }else {
                        self.serviceR.append(service)
                    }
                }
            }
            
            if self.serviceG.isEmpty {
                self.sections = [.notwork, .tips]
            }else if self.serviceR.isEmpty {
                self.sections = [.normal, .tips]
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.loadingOverlay?.removeFromSuperview()
                if self.serviceG.count == 1 {
                    let service = self.serviceG[0]
                    self.navigationController?.pushViewController(CityBusStopResultViewController(busViewModel: self.busViewModel, busService: service), animated: true)
                }
            }
        }
    }
    
    // MARK: - Table View delegate and datasource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionType = sections[section]
        switch sectionType {
        case .normal:
            return serviceG.count
        case .notwork:
            return serviceR.count
        case .tips:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionType = sections[section]
        switch sectionType {
        case .normal:
            return "正在服務"
        case .notwork:
            return "下列班次未來60分鐘沒有班次由總站開出"
        case .tips:
            return "小提示\n\n收藏車站建議選擇正常路線收藏\n瀏覽收藏車站時所顯示的到站時間會因應收藏路線而不同"
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionType = sections[indexPath.section]
        
        switch sectionType {
        case .normal:
            let service = serviceG[indexPath.row]
            let cell: ServiceTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.tagColorBackground.backgroundColor = .green
            cell.titleLabel.text = service.description
            return cell
        case .notwork:
            let service = serviceR[indexPath.row]
            let cell: ServiceTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.tagColorBackground.backgroundColor = .red
            cell.titleLabel.text = service.description
            return cell
        case .tips:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let sectionType = sections[indexPath.section]
        
        switch sectionType {
        case .normal:
            let service = serviceG[indexPath.row]
            navigationController?.pushViewController(CityBusStopResultViewController(busViewModel: busViewModel, busService: service), animated: true)
        case .notwork:
            let service = serviceR[indexPath.row]
            navigationController?.pushViewController(CityBusStopResultViewController(busViewModel: busViewModel, busService: service), animated: true)
        default:
            break
        }
    }
}
