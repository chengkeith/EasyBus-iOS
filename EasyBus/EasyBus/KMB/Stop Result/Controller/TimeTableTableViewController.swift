//
//  TimeTableTableViewController.swift
//  EasyBus
//
//  Created by KL on 6/11/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import UIKit

class TimeTableTableViewController: KLBottomCardTableViewController, UITableViewDataSource, UITableViewDelegate, HasLoadingOverlay {
    
    var loadingOverlay: LoadingOverlay?
    let specialServiceLabel = InsetLabel(insets: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8))
    var bus: BusData
    var datasource: [(String, [KMBScheduleModel])] = []
    
    init(bus: BusData) {
        self.bus = bus
        super.init(style: .plain)
    }
    
    deinit {
        print("time table deinit")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.darkGray, NSAttributedStringKey.font: EasyBusFont.font(type: .heavy, 20)]
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TimeTableTableViewCell.self)
        
        customShowLoadingOverlay()
        APIManager.shared.getKMBSchedule(bus: bus) { (error, data) in
            if let data = data {
                self.convertKMBScheduleToTableViewData(scheduleData: data)
            }
        }
    }
    
    override func setupAutoLayout() {
        specialServiceLabel.font = EasyBusFont.font(type: .regular, 16)
        specialServiceLabel.textColor = .darkGray
        specialServiceLabel.numberOfLines = 0
        
        contentView.add(specialServiceLabel)
        let views = ["tableView": tableView,
                     "navigationBar": navigationBar,
                     "specialServiceLabel": specialServiceLabel]
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[navigationBar(40)]-4-[tableView(\(ScreenSizeManager.screenHeight - 180))][specialServiceLabel(60)]|", options: [.alignAllLeft, .alignAllRight], metrics: nil, views: views))
        tableView.al_fillSuperViewHorizontally()
    }
    
    private func convertKMBScheduleToTableViewData(scheduleData: [KMBScheduleModel]) {
        DispatchQueue.main.async {
            var i = 0
            while i < scheduleData.count {
                var temp: (String, [KMBScheduleModel]) = (scheduleData[i].dayString, [scheduleData[i]])
                i += 1
                while i < scheduleData.count, scheduleData[i].dayString == temp.0 {
                    temp.1.append(scheduleData[i])
                    i += 1
                }
                self.datasource.append(temp)
            }
            self.loadingOverlay?.removeFromSuperview()
            self.specialServiceLabel.text = self.datasource.first?.1.first?.serviceType
            self.tableView.reloadData()
        }
    }
    
    // MARK: - LoadingOverlay
    
    func customShowLoadingOverlay() {
        let loadingOverlay: LoadingOverlay
        if let _loadingOverlay = self.loadingOverlay {
            loadingOverlay = _loadingOverlay
        }
        else {
            loadingOverlay = LoadingOverlay()
            loadingOverlay.translatesAutoresizingMaskIntoConstraints = false
            self.loadingOverlay = loadingOverlay
        }
        
        contentView.addSubview(loadingOverlay)
        loadingOverlay.leadingAnchor.constraint(equalTo: navigationBar.leadingAnchor).isActive = true
        loadingOverlay.trailingAnchor.constraint(equalTo: navigationBar.trailingAnchor).isActive = true
        loadingOverlay.topAnchor.constraint(equalTo: tableView.topAnchor).isActive = true
        loadingOverlay.bottomAnchor.constraint(equalTo: specialServiceLabel.bottomAnchor).isActive = true
    }
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let stackView = TimeTableTitleStackView()
        stackView.leftLabel.text = datasource[section].0
        stackView.rightLabel.text = "班次（分鐘）"
        
        return stackView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 24
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return datasource[section].0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 24
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return datasource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource[section].1.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let schedule = datasource[indexPath.section].1[indexPath.row]
        let bound = Int(bus.bound)
        
        let cell: TimeTableTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.periodString = schedule.getBoundText(bound: bound)
        cell.frequencyString = schedule.getBoundTime(bound: bound)
        cell.isCurrentPeriod = schedule.isCurrentPeriod(bound: bound)
        
        return cell
    }
}
