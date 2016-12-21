//
//  WebBrowserViewController.swift
//  WebBrowserSample
//
//  Created by 黄明 on 2016/12/19.
//  Copyright © 2016年 Danis. All rights reserved.
//

import UIKit
import WebKit


private var KVOContext = "com.danis.WebBrowser.WebBrowserViewController.KVOContext"

class JustForBundle {}

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
    fileprivate var moreItem:UIBarButtonItem!
    
    fileprivate var loadingToolbarItems: [UIBarButtonItem]!
    fileprivate var normalToolbarItems: [UIBarButtonItem]!
    
    public var tintColor = UIColor.blue {
        didSet {
            navigationController?.navigationBar.tintColor = tintColor
            navigationController?.toolbar.tintColor = tintColor
        }
    }
    public var barTintColor: UIColor? = nil {
        didSet {
            navigationController?.navigationBar.barTintColor = barTintColor
            navigationController?.toolbar.barTintColor = barTintColor
        }
    }
    public var isActionEnabled: Bool = true {
        didSet {
            updateToolbar()
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
        hidesBottomBarWhenPushed = true
        
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: &KVOContext)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        assert(navigationController != nil, "BrowserWebViewController must be embeded in UINavigationController")
        
        if navigationController!.viewControllers.first == self {
            // WebBrowser is rootViewController
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(onActionClose(sender:)))
        }
        let newTint = tintColor
        let newBarTint = barTintColor
        tintColor = newTint             // apply the tint color for navigationController
        barTintColor = newBarTint       // apply the barTint color for navigationController
        
        webView.frame = view.bounds
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.navigationDelegate = self
        webView.uiDelegate = self
        
        progressView.frame = CGRect(x: 0,
                                    y: navigationController!.navigationBar.bounds.maxY - progressView.frame.height,
                                    width: navigationController!.navigationBar.bounds.width,
                                    height: progressView.frame.height)
        progressView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        view.addSubview(webView)
        navigationController!.navigationBar.addSubview(progressView)
    }
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.setToolbarHidden(false, animated: true)
        
        updateToolbar()
        navigationController?.setToolbarHidden(false, animated: false)
    }
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setToolbarHidden(true, animated: false)
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

extension WebBrowserViewController {
    func onActionBack(sender: AnyObject) {
        webView.goBack()
        
        updateToolbar()
    }
    func onActionForward(sender: AnyObject) {
        webView.goForward()
        
        updateToolbar()
    }
    func onActionRefresh(sender: AnyObject) {
        webView.stopLoading()
        webView.reload()
    }
    func onActionStop(sender: AnyObject) {
        webView.stopLoading()
    }
    func onActionMore(sender: AnyObject) {
        guard let url = webView.url else {
            return
        }
        let activityController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        
        present(activityController, animated: true, completion: nil)
    }
    func onActionClose(sender: AnyObject) {
        dismiss(animated: true, completion: nil)
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
        tintColor = UIColor.blue
        barTintColor = UIColor.white
        let bundle = Bundle(for: type(of: JustForBundle.self()))
        let backIcon = UIImage(named: "back-item", in: bundle, compatibleWith: nil)
        let forwardIcon = UIImage(named: "forward-item", in: bundle, compatibleWith: nil)
        
        refreshItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(onActionRefresh(sender:)))
        stopItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(onActionStop(sender:)))
        backItem = UIBarButtonItem(image: backIcon, style: .plain, target: self, action: #selector(onActionBack(sender:)))
        forwardItem = UIBarButtonItem(image: forwardIcon, style: .plain, target: self, action: #selector(onActionForward(sender:)))
        moreItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(onActionMore(sender:)))
        
        let fixedSeparator = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        let flexibleSeparator = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        fixedSeparator.width = 36
        
        loadingToolbarItems = [backItem, fixedSeparator, forwardItem, fixedSeparator, stopItem, flexibleSeparator, moreItem]
        normalToolbarItems = [backItem, fixedSeparator, forwardItem, fixedSeparator, refreshItem, flexibleSeparator, moreItem]
        
        setToolbarItems(loadingToolbarItems, animated: false)
    }
    fileprivate func updateToolbar() {
        backItem.isEnabled = webView.canGoBack
        forwardItem.isEnabled = webView.canGoForward
        
        if webView.isLoading {
            if !isActionEnabled {
                let itemsWithoutAction = loadingToolbarItems[0..<loadingToolbarItems.count - 2]
                setToolbarItems(Array(itemsWithoutAction), animated: true)
            } else {
                setToolbarItems(loadingToolbarItems, animated: true)
            }
        } else {
            if !isActionEnabled {
                let itemsWithoutAction = normalToolbarItems[0..<normalToolbarItems.count - 2]
                setToolbarItems(Array(itemsWithoutAction), animated: true)
            } else {
                setToolbarItems(normalToolbarItems, animated: true)
            }
        }
    }
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &KVOContext && keyPath == "estimatedProgress" else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            
            return
        }
        progressView.alpha = 1
        progressView.setProgress(Float(webView.estimatedProgress), animated: Float(webView.estimatedProgress) > progressView.progress)
        if webView.estimatedProgress >= 1 {
            self.progressView.alpha = 0
            self.progressView.setProgress(0, animated: false)
        }
        
    }
}

extension WebBrowserViewController {
    public override var shouldAutorotate: Bool {
        return true
    }
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
}
