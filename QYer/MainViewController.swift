//
//  MainViewController.swift
//  QYer
//
//  Created by linhan on 15-4-6.
//  Copyright (c) 2015年 linhan. All rights reserved.
//

import UIKit
extension UIViewController
{
    //导航栏上的加载进度条
    var incrementProgressView:IncrementProgressView?
    {
        if self.navigationController != nil
        {
            var barSubviews = self.navigationController!.navigationBar.subviews
            for i in 0..<barSubviews.count
            {
                if barSubviews[i] is IncrementProgressView
                {
                    return barSubviews[i] as? IncrementProgressView
                }
            }
        }
        return nil
    }
    
    
    var VCBackgroundColor:UIColor
    {
        return UIColor(white: 230 / 250, alpha: 1)
    }
    
    
}

class MainViewController: UITabBarController
{
    private var _presentedIntroView:Bool = false
    
    
    //打开搜索
    var _searchBtn:UIBarButtonItem?
    private var _searchViewController:InfoSearchViewController?
    private var _searchViewContainer:UINavigationController?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setup()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        presentIntroView()
        println("MainViewController viewDidAppear")
    }
    
    private func presentIntroView()
    {
        if !_presentedIntroView
        {
            _presentedIntroView = true
            var viewController:UIViewController = IntroViewController()
            viewController.modalPresentationStyle = UIModalPresentationStyle.FullScreen
            viewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve;
            self.presentViewController(viewController, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    private func setup()
    {
        println("MainViewController init")
        //var a:UITabBarController
        
        self.title = "穷游"
        
        if self.navigationController != nil
        {
            AppConfig.shared().navigationBarHeight = self.navigationController!.navigationBar.height
            
            //进度条
            if self.incrementProgressView == nil
            {
                var progressView:IncrementProgressView = IncrementProgressView(frame: CGRectMake(0, AppConfig.shared().navigationBarHeight - 2, self.view.width, 2))
                self.navigationController!.navigationBar.addSubview(progressView)
            }
        }
        
        if self.tabBarController != nil
        {
            var tabBarHeight:CGFloat = self.tabBarController!.tabBar.height
            AppConfig.shared().tabBarHeight = tabBarHeight
            println("tabBarHeight:\(tabBarHeight)")
        }
        
        
        
        
    }
    
    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem!)
    {
        println("didSelectItem:\(item.title)")
        self.title = item.title == "" ? "穷游" : item.title
        if item.tag == 1 || item.tag == 2
        {
            if _searchBtn == nil
            {
                _searchBtn = UIBarButtonItem(image: UIImage(named:"btn_search.png")!, style: UIBarButtonItemStyle.Done, target: self, action: "searchBtnTapped")
            }
            //searchBtn = UIBarButtonItem(title: "搜索", style: UIBarButtonItemStyle.Done, target: self, action:  "searchBtnTapped")
            self.navigationItem.rightBarButtonItem = _searchBtn!
        }
        else
        {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    
    @objc private func searchBtnTapped()
    {
        var searchViewController:UIViewController
        if self.selectedIndex == 1
        {
            searchViewController = DestinationSearchViewController()
        }
        else
        {
            searchViewController = InfoSearchViewController()
        }
        var searchViewContainer = UINavigationController(rootViewController: searchViewController)
        self.presentViewController(searchViewContainer, animated: true, completion: nil)
        /**
        if _searchViewController == nil
        {
            _searchViewController = InfoSearchViewController()
            _searchViewContainer = UINavigationController(rootViewController: _searchViewController!)
        }
        self.presentViewController(_searchViewContainer!, animated: true, completion: nil)
        **/
    }
    
    
    
    
}
