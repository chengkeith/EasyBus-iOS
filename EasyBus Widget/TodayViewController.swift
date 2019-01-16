//
//  TodayViewController.swift
//  EasyBus Widget
//
//  Created by KL on 8/11/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var models: [StarredStopViewModel] = []
    var reloadTableViewTimer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        preferredContentSize = CGSize(width: self.view.frame.size.width, height: 110)
        extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(EtaTableViewCell.self)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        reloadTableViewTimer.invalidate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NSKeyedArchiver.setClassName("StarredStopModel", for: StarredStopModel.self)
        NSKeyedUnarchiver.setClass(StarredStopModel.self, forClassName: "StarredStopModel")
        if let suite = UserDefaults.init(suiteName: "group.kl.easybus.widget") {
            if let decodedData = suite.data(forKey: "KMBStarredStops"), let stops = NSKeyedUnarchiver.unarchiveObject(with: decodedData) as? [StarredStopModel] {
                models = stops[0..<min(stops.count, 5)].map({ (model) -> StarredStopViewModel in
                    return StarredStopViewModel(model: model)
                })
                self.tableView.reloadData()
            }
        }
        startReloadTableViewTimer()
    }
    
    @IBAction func RefreshButtonOnClicked(_ sender: Any) {
        models.forEach { (model) in
            model.shouldFetchEta = true
        }
        tableView.reloadData()
    }
    
    @IBAction func openEasyBusButton(_ sender: Any) {
        extensionContext?.open(URL(string: "easybus://star")! , completionHandler: nil)
    }
    
    private func startReloadTableViewTimer() {
        reloadTableViewTimer.invalidate()
        reloadTableViewTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(reloadTableView), userInfo: nil, repeats: true)
    }
    
    private func getEta(routeStop qeuriableStop: StopQeuriable, callback: @escaping (_ error: Error?, _ result: [EtaModel]?) -> Void) {
        
        let query: [String: String] = [
            "action": "geteta",
            "lang": "tc",
            "route": qeuriableStop.route,
            "bound": qeuriableStop.bound,
            "stop": qeuriableStop.bsiCode.replacingOccurrences(of: "-", with: ""),
            "stop_seq": qeuriableStop.seq,
            "servicetype": qeuriableStop.serviceType
        ]
        
        NetworkManager.decodableGet(url: "http://40.83.75.233", query: query) { (error, result: EtaResultModel?) in
            callback(error, result?.etas)
        }
    }
    
    @objc func reloadTableView() {
        print("Timer reloadTableView")
        tableView.reloadData()
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize){
        let deadlineTime = DispatchTime.now() + 0.2
        if activeDisplayMode == .expanded {
            DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                self.preferredContentSize = CGSize(width: 0.0, height: 400)
            }
        } else if activeDisplayMode == .compact {
            DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                self.preferredContentSize = maxSize
            }
        }
    }
    
    // MARK: - table view delegate and datasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: EtaTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        let model = models[indexPath.row]
        
        cell.routeNumberLabel.text = model.route
        cell.stopNameLabel.attributedText = model.stopAttributedString
        cell.etaLabel.text = model.etaDisplayString
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let viewModel = models[indexPath.row]
        print("willDisplay", indexPath)
        
        if viewModel.shouldFetchEta {
            viewModel.shouldFetchEta = false
            getEta(routeStop: viewModel.stopModel) { (error, etaModels) in
                DispatchQueue.main.async {
                    viewModel.firstEta = etaModels?.first
                    self.tableView.reloadData()
                }
            }
        }
    }
    
}
