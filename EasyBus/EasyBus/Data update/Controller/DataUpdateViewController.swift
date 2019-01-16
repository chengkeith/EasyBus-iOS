//
//  DataUpdateViewController.swift
//  EasyBus
//
//  Created by KL on 22/10/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import UIKit

class DataUpdateViewController: KLViewController, URLSessionDownloadDelegate {
    
    fileprivate let circleProgressView = CircleProgressView()
    fileprivate let fileSizeLabel = DULabel()
    fileprivate let currentVersionLabel = DULabel()
    fileprivate let serverVersionLabel = DULabel()
    fileprivate var isDownloading = false
    var urlSession: URLSession?
    
    deinit {
        print("DataUpdateViewController deinit")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isMovingFromParentViewController {
            urlSession?.invalidateAndCancel()
            urlSession = nil
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadContent()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        
        title = "更新資料"
        fileSizeLabel.text = "更新檔案大小：10MB"
        circleProgressView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapCircleProgressView)))
        safeAreaContentView.add(circleProgressView, currentVersionLabel, serverVersionLabel, fileSizeLabel)
        
        let views = ["circleProgressView": circleProgressView,
                     "serverVersionLabel": serverVersionLabel,
                     "currentVersionLabel": currentVersionLabel,
                     "fileSizeLabel": fileSizeLabel]
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|-16-[circleProgressView(208)]-24-[fileSizeLabel]-8-[currentVersionLabel]-8-[serverVersionLabel]", options: [.alignAllLeft, .alignAllRight], metrics: nil, views: views))
        circleProgressView.al_fillSuperViewHorizontally()
        circleProgressView.layoutSubviews()
    }
    
    func reloadContent() {
        DispatchQueue.main.async {
            self.currentVersionLabel.text = "當前版本：" + String(KMBDataManager.shared.version)
            self.serverVersionLabel.text = "最新版本：" + String(AppManager.shared.dataVersion)
            self.circleProgressView.reloadContent()
            self.isDownloading = false
        }
    }
    
    @objc func handleDownloadCompleted() {
        reloadContent()
    }
    
    @objc func didTapCircleProgressView() {
        if !isDownloading, AppManager.shared.dataUpdateRequired {
            beginDownloadingFile()
        }
    }
    
    // MARK: - URLSessionDownloadDelegate
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let precentage = CGFloat(totalBytesWritten) / CGFloat(totalBytesExpectedToWrite)
        
        circleProgressView.updateProgress(precentage: precentage)
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let destinationFileUrl = documentDirectory.appendingPathComponent("kmbData.json")
            do {
                try FileManager.default.replaceItem(at: destinationFileUrl, withItemAt: location, backupItemName: "backup", options: FileManager.ItemReplacementOptions.usingNewMetadataOnly, resultingItemURL: nil)
                print("save to \(destinationFileUrl)")
                try KMBDataManager.shared.initFromDisk()
                self.handleDownloadCompleted()
                return
            } catch KmbDataError.initFromDiskFail {
                print("download but fail to reload")
            } catch (let writeError) {
                print("Error creating a file \(destinationFileUrl) : \(writeError)")
            }
        }else {
            print("no documentDirectory")
        }
    }
}

extension DataUpdateViewController {
    
    private func beginDownloadingFile() {
        guard let url = URL(string: AppManager.shared.kmbDataDownloadLink) else { return }
        let downloadTask = urlSession?.downloadTask(with: url)
        
        circleProgressView.progressShapeLayer.strokeEnd = 0
        isDownloading = true
        downloadTask?.resume()
    }
}

fileprivate class DULabel: UILabel {
    
    init() {
        super.init(frame: .zero)
        
        textAlignment = .center
        textColor = EasyBusColor.appColor
        font = EasyBusFont.font(type: .regular, 16)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
