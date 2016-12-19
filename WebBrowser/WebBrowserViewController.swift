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
    public var didFinishLoadingUrlHandler: ((URL, Bool) -> Void)?
    
    let webView: WKWebView
    
    fileprivate var refreshItem: UIBarButtonItem!
    fileprivate var stopItem: UIBarButtonItem!
    fileprivate var backItem: UIBarButtonItem!
    fileprivate var forwardItem: UIBarButtonItem!
    
    
    public init(configuration: WKWebViewConfiguration) {
        webView = WKWebView(frame: CGRect(), configuration: configuration)
        
        super.init(nibName: nil, bundle: nil)
    }
    public init() {
        webView = WKWebView()
        
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        setupToolbar()
        
        webView.frame = view.bounds
        webView.navigationDelegate = self
        webView.uiDelegate = self
        
        view.addSubview(webView)
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
            didFinishLoadingUrlHandler?(url, true)
        }
    }
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        updateToolbar()
        if let url = webView.url {
            didFinishLoadingUrlHandler?(url, false)
        }
    }
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        updateToolbar()
        if let url = webView.url {
            didFinishLoadingUrlHandler?(url, false)
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
