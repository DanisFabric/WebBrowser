//
//  ViewController.swift
//  WebBrowserSample
//
//  Created by 黄明 on 2016/12/19.
//  Copyright © 2016年 Danis. All rights reserved.
//

import UIKit
import WebBrowser

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func onBrowser(_ sender: Any) {
        let browser = WebBrowserViewController()
        browser.load(urlString: "https://bing.com")
        
        browser.didStartLoadingUrlHandler = { (url) in
            print("start to load \(url)")
        }
        browser.didFinishLoadingUrlHandler = { (url) in
            print("succeed to load \(url)")
        }
        browser.didFailedLoadingUrlHandler = { (url, error) in
            print("failed to load \(url) - \(error)")
            
        }
        browser.isActionEnabled = false
        
        let nav = UINavigationController(rootViewController: browser)
        show(nav, sender: self)
        
    }
}

