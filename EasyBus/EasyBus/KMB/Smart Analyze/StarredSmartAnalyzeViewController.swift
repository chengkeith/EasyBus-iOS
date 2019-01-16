//
//  StarredSmartAnalyzeViewController.swift
//  EasyBus
//
//  Created by KL on 2/12/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import UIKit

class StarredSmartAnalyzeViewController: KLCustomTableViewController, HasEmptyTableView, ButtonRemindViewDelegate {
    
    private var models: [SmartAnalyzeModel] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    var emptyView: UIView  {
        get {
            return remindButton
        }
    }
    private let remindButton: ButtonRemindView = {
        let button = ButtonRemindView()
        button.remindTextLabel.text = "智能監測可以快速比較去相同目的地既巴士路線，快d係搜尋車站度設定好然後收藏啦！"
        button.remindButton.setTitle("前往搜尋", for: UIControlState())
        return button
    }()
    
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
    
    init() {
        super.init(style: .plain)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        emptyView.removeFromSuperview()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        models = StarSmartAnalyzeManager.shared.models
        showOrRemoveEmptyViewIfNeeded()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        remindButton.delegate = self
        navigationItem.title = "智能監測"
        navigationItem.removeBackButtonText()
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = editBarButton
        editBarButton.target = self
        editBarButton.action = #selector(didClickedEditBarButton)
    }
    
    @objc func didClickedEditBarButton() {
        isEditingTableView = !isEditingTableView
    }
    
    // MARK: - ButtonRemindViewDelegate
    
    func didClickedRemindViewButton(_ sender: UIButton) {
        tabBarController?.selectedIndex = TabBar.kmbSearch.rawValue
    }
    
    // MARK: - tableview datasource and delegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.row]
        let cell = UITableViewCell()
        
        cell.separatorInset = UIEdgeInsetsMake(0, 16, 0, 16)
        cell.textLabel?.text = model.name
        cell.textLabel?.numberOfLines = 0
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.font = EasyBusFont.font(type: .regular, 15)
        cell.textLabel?.textColor = .darkGray
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let model = models[indexPath.row]
        navigationController?.pushViewController(SmartAnalyzeViewController(starModel: model), animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        StarSmartAnalyzeManager.shared.deteleStopFromCollection(models[indexPath.row])
        tableView.beginUpdates()
        models.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "移除"
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let model = models[sourceIndexPath.row]
        StarSmartAnalyzeManager.shared.reOrderStops(from: sourceIndexPath.row, to: destinationIndexPath.row)
        models.remove(at: sourceIndexPath.row)
        models.insert(model, at: destinationIndexPath.row)
    }
}
