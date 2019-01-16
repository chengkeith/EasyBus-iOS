//
//  KMBTrafficNewsController.swift
//  EasyBus
//
//  Created by KL on 5/11/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import UIKit

class KMBTrafficNewsController: KLCustomTableViewController {
    
    var newsModel: KMBTrafficNewsModel?
    
    init() {
        super.init(style: .plain)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "交通消息"
        tableView.register(SettingBaseTableViewCell.self)
        navigationItem.removeBackButtonText()
        
        showLoadingOverlay(in: self.safeAreaContentView)
        APIManager.shared.getTrafficNews { (error, models) in
            if let models = models {
                self.newsModel = models
            }
            DispatchQueue.main.async {
                self.loadingOverlay?.removeFromSuperview()
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Table view delegate and datasource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsModel?.news.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let newsModel = newsModel else { return UITableViewCell() }
        
        let new = newsModel.news[indexPath.row]
        
        let cell: SettingBaseTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.textLabel?.text = new.kpiTitle
        cell.selectionStyle = .default
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let newsModel = newsModel else { return }
        let news = newsModel.news[indexPath.row]
        tabBarController?.present(KLWebViewBottomCardViewController(url: newsModel.urlprefix + news.kpiNoticeimageurl, title: news.kpiTitle), animated: true, completion: nil)
    }
}
