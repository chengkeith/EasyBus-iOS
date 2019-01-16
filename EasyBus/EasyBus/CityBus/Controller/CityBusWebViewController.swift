//
//  CityBusWebViewController.swift
//  EasyBus
//
//  Created by KL on 9/11/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import UIKit
import WebKit

class CityBusWebViewController: KLViewController, WKNavigationDelegate {
    
    var webView: WKWebView
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        webView = WKWebView(frame: .zero)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadingOverlay?.removeFromSuperview()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        safeAreaContentView.add(webView)
        webView.al_fillSafeAreaView(safeAreaContentView)
        showLoadingOverlay()
        webView.navigationDelegate = self
        let request = URLRequest(url: URL(string : APIManager.shared.djangoUrl("/cnweb"))!)
        webView.load(request)
        
        navigationItem.title = "城巴網頁版"
    }
}
