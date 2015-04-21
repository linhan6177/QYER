//
//  JournalDetailViewController.swift
//  QYer
//
//  Created by linhan on 15-4-9.
//  Copyright (c) 2015年 linhan. All rights reserved.
//

import Foundation
import UIKit
class WebViewController: UIViewController,UIWebViewDelegate
{
    var viewURL:String?
    //网页加载完成后自动获取设置标题
    var autoTitleAfterLoadedFinish:Bool = true
    private var _loaded:Bool = false
    private var _webView:UIWebView = UIWebView()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        if viewURL != nil && !_loaded
        {
            _webView.loadRequest(NSURLRequest(URL: NSURL(string: viewURL!)!))
        }
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        if self.navigationController == nil
        {
            _loaded = false
        }
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        if incrementProgressView != nil && incrementProgressView!.running
        {
            incrementProgressView!.reset()
        }
    }
    
    
    
    private func setup()
    {
        self.view.backgroundColor = UIColor.whiteColor()
        
        _webView.frame = self.view.bounds
        _webView.delegate = self
        self.view.addSubview(_webView)
    }
    
    
    func webViewDidStartLoad(webView: UIWebView!)
    {
        incrementProgressView?.start()
    }
    
    func webViewDidFinishLoad(webView: UIWebView!)
    {
        _loaded = true
        if autoTitleAfterLoadedFinish
        {
            var title:String? = webView.stringByEvaluatingJavaScriptFromString("document.title")
            if title != nil
            {
                self.title = title
            }
        }
        incrementProgressView?.finish()
    }
    
    
    
}//end class