//
//  StarredViewController.swift
//  EasyBus
//
//  Created by KL on 14/10/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import UIKit

class StarredViewController: StarStyleTableViewController, FoldableTitleViewDelegate {
    
    enum Section {
        case citybus
        case kmb
        case kmb2
        case mix
    }
    
    var starredViewModels2: [StarredStopViewModel] = []
    var sections: [Section] = [.kmb, .kmb2]
    var mainSection: Int? = 0 {
        didSet {
            tableView.reloadData()
        }
    }
    
    let tutorialButton = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_info"), style: .plain, target: nil, action: nil)
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
    
    // MARK: - Mix
    
    var mixStopsViewModel: [StarredCellItem] = []
    
    // MARK: - CNBus
    
    var cnStarredViewModels: [CNStarredStopViewModel] = []
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        isEditingTableView = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        handleDataInit()
        
        super.viewWillAppear(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGesture.minimumPressDuration = 1.0
        tableView.addGestureRecognizer(longPressGesture)
        
        navigationItem.leftBarButtonItem = tutorialButton
        tutorialButton.target = self
        tutorialButton.action = #selector(didClicktutorialButton)
        
        navigationItem.rightBarButtonItem = editBarButton
        editBarButton.target = self
        editBarButton.action = #selector(didClickedEditBarButton)
        
        navigationItem.title = "收藏"
    }
    
    // MARK: - Init
    
    private func handleDataInit() {
        var kmbRoutes: [String] = []
        var cityBusRoutes: [String] = []
        starredViewModels = StarredManager.shared.starredStops.map { (starredStopModel) -> StarredStopViewModel in
            kmbRoutes.append(starredStopModel.route)
            return StarredStopViewModel(starredStopModel: starredStopModel)
        }
        starredViewModels2 = StarredManager.shared2.starredStops.map { (starredStopModel) -> StarredStopViewModel in
            kmbRoutes.append(starredStopModel.route)
            return StarredStopViewModel(starredStopModel: starredStopModel)
        }
        cnStarredViewModels = StarredManager.shared.cnStarredStops.map { (model) -> CNStarredStopViewModel in
            cityBusRoutes.append(model.route)
            return CNStarredStopViewModel(starredStopModel: model)
        }
        
        mixStopsViewModel = []
        let commanRouteNumber = Array(Set(kmbRoutes).intersection(Set(cityBusRoutes)))
        commanRouteNumber.forEach { (route) in
            starredViewModels.forEach({ (model) in
                if model.starredStopModel.route == route {
                    mixStopsViewModel.append(model)
                }
            })
            cnStarredViewModels.forEach({ (model) in
                if model.starredStopModel.route == route {
                    mixStopsViewModel.append(model)
                }
            })
        }
        
        tableView.reloadData()
    }
    
    // MARK: - Method
    
    @objc func didClicktutorialButton() {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "starstop_guide"))
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = EasyBusColor.appColor
        tabBarController?.present(GenericBottomCardViewController<UIImageView>(view: imageView), animated: true, completion:  nil)
    }
    
    @objc func didClickedEditBarButton() {
        targetIndexPath = nil
        isEditingTableView = !isEditingTableView
    }
    
    override func refreshEtaFromNetwork() {
        print("all model should fetch eta")
        starredViewModels.forEach { (model) in
            model.shouldFetchEta = true
        }
        cnStarredViewModels.forEach { (model) in
            model.shouldFetchEta = true
        }
        tableView.reloadData()
    }
    
    override func fetchStopsEta(at indexPath: IndexPath) {
        switch sections[indexPath.section] {
        case .kmb:
            let model = starredViewModels[indexPath.row]
            fetchKmbStopEta(model: model)
        case .kmb2:
            let model = starredViewModels2[indexPath.row]
            fetchKmbStopEta(model: model)
        case .citybus:
            let model = cnStarredViewModels[indexPath.row]
            fetchCNStopEta(model: model)
        case .mix:
            if let model = mixStopsViewModel[indexPath.row] as? CNStarredStopViewModel {
                fetchCNStopEta(model: model)
            }else if let model = mixStopsViewModel[indexPath.row] as? StarredStopViewModel {
                fetchKmbStopEta(model: model)
            }
        }
    }
    
    func fetchCNStopEta(model: CNStarredStopViewModel) {
        if !tableView.isEditing {
            if model.shouldFetchEta {
                model.shouldFetchEta = false
                APIManager.shared.getCNBusEta(starredModel: model.starredStopModel) { (error, etas) in
                    guard let etas = etas else { return }
                    DispatchQueue.main.async {
                        model.etaViewModel = CNBusEtaViewModel(etas: etas)
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    // MARK: - longPress
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer){
        
        if gestureRecognizer.state == .began {
            let touchPoint = gestureRecognizer.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                switch sections[indexPath.section] {
                case .kmb:
                    if let window = UIApplication.shared.keyWindow {
                        let model = starredViewModels[indexPath.row].starredStopModel
                        StarredManager.shared2.append(model)
                        KLAlertViewManager().showTopAlert(target: window, size: CGSize(width: ScreenSizeManager.windowWidth, height: 54), contentInset: UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0), text: "已複製至 － 副收藏")
                        handleDataInit()
                    }
                default:
                    if let window = UIApplication.shared.keyWindow {
                        KLAlertViewManager().showTopAlert(target: window, size: CGSize(width: ScreenSizeManager.windowWidth, height: 54), contentInset: UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0), text: "沒有長按功能")
                    }
                }
            }
        }
    }
    
    // MARK: - FoldableTitleViewDelegate
    
    func didTapSection(section: Int) {
        isEditingTableView = false
        if mainSection == section {
            mainSection = nil
        }else {
            mainSection = section
        }
    }
    
    // MARK: - Table view delegate and datasource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard mainSection != nil, section == mainSection else { return 0 }
        
        switch sections[section] {
        case .kmb:
            return starredViewModels.count
        case .kmb2:
            return starredViewModels2.count
        case .citybus:
            return cnStarredViewModels.count
        case .mix:
            return mixStopsViewModel.count
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = FoldableTitleView()
        
        switch sections[section] {
        case .kmb:
            headerView.backgroundColor = StarredStopViewModel.tagColor
            headerView.titleLabel.text = "九巴收藏"
        case .kmb2:
            headerView.backgroundColor = StarredStopViewModel.tagColor2
            headerView.titleLabel.text = "副收藏"
        case .citybus:
            headerView.backgroundColor = CNStarredStopViewModel.tagColor
            headerView.titleLabel.text = "城巴／新巴"
        case .mix:
            headerView.backgroundColor = UIColor.lightGray
            headerView.titleLabel.text = "混合 (相同巴士線)"
        }
        
        if mainSection == section {
            headerView.transformArrowToUpward()
        }
        headerView.delegate = self
        headerView.section = section
        
        return headerView
//        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 0
        return 40
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: StarredEtaTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        let starredViewModel: StarredCellItem
        
        switch sections[indexPath.section] {
        case .kmb:
            starredViewModel = starredViewModels[indexPath.row]
            cell.colorTagView.backgroundColor = StarredStopViewModel.tagColor
        case .kmb2:
            starredViewModel = starredViewModels2[indexPath.row]
            cell.colorTagView.backgroundColor = StarredStopViewModel.tagColor2
        case .citybus:
            starredViewModel = cnStarredViewModels[indexPath.row]
            cell.colorTagView.backgroundColor = CNStarredStopViewModel.tagColor
        case .mix:
            starredViewModel = mixStopsViewModel[indexPath.row]
        }
        cell.routeNumberLabel.text = starredViewModel.routeString
        cell.etaLabel.text = starredViewModel.etaRemainingMinuteString
        
        if let starredViewModel = starredViewModel as? CNStarredStopViewModel {
            cell.colorTagView.backgroundColor = CNStarredStopViewModel.tagColor
            cell.configEtaView(starredViewModel: starredViewModel, isTarget: indexPath == targetIndexPath)
        }else if let starredViewModel = starredViewModel as? StarredStopViewModel {
            cell.colorTagView.backgroundColor = StarredStopViewModel.tagColor
            cell.configEtaView(starredViewModel: starredViewModel, isTarget: indexPath == targetIndexPath)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        startReloadTableViewTimer()
        targetIndexPath = indexPath
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch sections[indexPath.section] {
        case .kmb:
            if editingStyle == .delete {
                StarredManager.shared.deteleStopFromCollection(starredViewModels[indexPath.row].starredStopModel)
                tableView.beginUpdates()
                starredViewModels.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                tableView.endUpdates()
            }
        case .kmb2:
            if editingStyle == .delete {
                StarredManager.shared2.deteleStopFromCollection(starredViewModels2[indexPath.row].starredStopModel)
                tableView.beginUpdates()
                starredViewModels2.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                tableView.endUpdates()
            }
        case .citybus:
            StarredManager.shared.cnDeteleStopFromCollection(cnStarredViewModels[indexPath.row].starredStopModel)
            tableView.beginUpdates()
            cnStarredViewModels.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        case .mix:
            return
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch sections[indexPath.section] {
        case .mix:
            return false
        default:
            return true
        }
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if mainSection == section, sections[section] == .mix, mixStopsViewModel.count > 0 {
            return "*只顯示已收藏的車站"
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "移除"
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//        print("destinationIndexPath")
        switch sections[sourceIndexPath.section] {
        case .kmb:
            let movedObject = starredViewModels[sourceIndexPath.row]
            StarredManager.shared.reOrderStops(from: sourceIndexPath.row, to: destinationIndexPath.row)
            starredViewModels.remove(at: sourceIndexPath.row)
            starredViewModels.insert(movedObject, at: destinationIndexPath.row)
        case .kmb2:
            let movedObject = starredViewModels2[sourceIndexPath.row]
            StarredManager.shared2.reOrderStops(from: sourceIndexPath.row, to: destinationIndexPath.row)
            starredViewModels2.remove(at: sourceIndexPath.row)
            starredViewModels2.insert(movedObject, at: destinationIndexPath.row)
        case .citybus:
            let movedObject = cnStarredViewModels[sourceIndexPath.row]
            StarredManager.shared.cnReOrderStops(from: sourceIndexPath.row, to: destinationIndexPath.row)
            cnStarredViewModels.remove(at: sourceIndexPath.row)
            cnStarredViewModels.insert(movedObject, at: destinationIndexPath.row)
        case .mix:
            return
        }
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
//        print("proposedDestinationIndexPath")
        if sourceIndexPath.section != proposedDestinationIndexPath.section {
            return sourceIndexPath
        }
        return proposedDestinationIndexPath
    }
}
