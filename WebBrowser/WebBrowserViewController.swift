//
//  WebBrowserViewController.swift
//  WebBrowserSample
//
//  Created by 黄明 on 2016/12/19.
//  Copyright © 2016年 Danis. All rights reserved.
//

import UIKit
import WebKit


public class WebBrowserViewController: UIViewController {
    public var didStartLoadingUrlHandler: ((URL) -> Void)?
    public var didFinishLoadingUrlHandler: ((URL) -> Void)?
    public var didFailedLoadingUrlHandler: ((URL, Error) -> Void)?
    
    let webView: WKWebView
    
    fileprivate let progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.trackTintColor = UIColor.clear
        
        return progressView
    }()
    fileprivate var refreshItem: UIBarButtonItem!
    fileprivate var stopItem: UIBarButtonItem!
    fileprivate var backItem: UIBarButtonItem!
    fileprivate var forwardItem: UIBarButtonItem!
    
    var tintColor = UIColor.blue {
        didSet {
            
        }
    }
    var barTintColor = UIColor.blue {
        didSet {
            
        }
    }
    
    public init(configuration: WKWebViewConfiguration? = nil) {
        if let configuration = configuration {
            webView = WKWebView(frame: CGRect(), configuration: configuration)
        } else {
            webView = WKWebView()
        }
        super.init(nibName: nil, bundle: nil)
        
        setupToolbar()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        assert(navigationController != nil, "BrowserWebViewController must be embeded in UINavigationController")
        
        webView.frame = view.bounds
        webView.navigationDelegate = self
        webView.uiDelegate = self
        
        progressView.frame = CGRect(x: 0,
                                    y: navigationController!.navigationBar.bounds.maxY - progressView.frame.height,
                                    width: navigationController!.navigationBar.bounds.width,
                                    height: progressView.frame.height)
        
        
        view.addSubview(webView)
        navigationController!.navigationBar.addSubview(progressView)
    }
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateToolbar()
        navigationController?.setToolbarHidden(false, animated: false)
    }
}

extension WebBrowserViewController {
    public  func load(request: URLRequest) {
        webView.load(request)
    }
    public func load(url: URL) {
        load(request: URLRequest(url: url))
    }
    public func load(urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }
        load(url: url)
        
    }
    public func load(html: String) {
        webView.loadHTMLString(html, baseURL: nil)
    }
}


// MARK: - Public Configurations
extension WebBrowserViewController {
    public var refreshIcon: UIImage? {
        get {
            return refreshItem.image
        }
        set {
            refreshItem.image = newValue
        }
    }
    public var stopIcon: UIImage? {
        get {
            return stopItem.image
        }
        set {
            stopItem.image = newValue
        }
    }
    public var backIcon: UIImage? {
        get {
            return backItem.image
        }
        set {
            backItem.image = newValue
        }
    }
    public var forwardIcon: UIImage? {
        get {
            return forwardItem.image
        }
        set {
            forwardItem.image = newValue
        }
    }
}

extension WebBrowserViewController {
    @objc fileprivate func onActionBack(sender: AnyObject) {
        webView.goBack()
        
        updateToolbar()
    }
    @objc fileprivate func onActionForward(sender: AnyObject) {
        webView.goForward()
        
        updateToolbar()
    }
    @objc fileprivate func onActionRefresh(sender: AnyObject) {
        webView.stopLoading()
        webView.reload()
    }
    @objc fileprivate func onActionStop(sender: AnyObject) {
        webView.stopLoading()
    }
}

extension WebBrowserViewController: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        updateToolbar()
        if let url = webView.url {
            didStartLoadingUrlHandler?(url)
        }
    }
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        updateToolbar()
        if let url = webView.url {
            didFinishLoadingUrlHandler?(url)
        }
    }
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        updateToolbar()
        if let url = webView.url {
            didFailedLoadingUrlHandler?(url, error)
        }
    }
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        updateToolbar()
        if let url = webView.url {
            didFailedLoadingUrlHandler?(url, error)
        }
    }
}

extension WebBrowserViewController: WKUIDelegate {
//    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
//        
//    }
}

extension WebBrowserViewController {
    fileprivate func setupToolbar() {
        refreshItem = UIBarButtonItem(title: "refresh", style: .plain, target: self, action: #selector(onActionRefresh(sender:)))
        stopItem = UIBarButtonItem(title: "stop", style: .plain, target: self, action: #selector(onActionStop(sender:)))
        backItem = UIBarButtonItem(title: "back", style: .plain, target: self, action: #selector(onActionBack(sender:)))
        forwardItem = UIBarButtonItem(title: "forward", style: .plain, target: self, action: #selector(onActionForward(sender:)))
        
        setToolbarItems([backItem, forwardItem, refreshItem, stopItem], animated: false)
    }
    fileprivate func updateToolbar() {
        backItem.isEnabled = webView.canGoBack
        forwardItem.isEnabled = webView.canGoForward
        
        
    }
}
