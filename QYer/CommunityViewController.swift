//
//  CommunityViewController.swift
//  QYer
//
//  Created by linhan on 15-4-6.
//  Copyright (c) 2015年 linhan. All rights reserved.
//

import UIKit

class CommunityViewController: UIViewController {
    
    struct Item
    {
        var name:String?
        var code:Int?
        var icon:String?
    }
    
    struct Category
    {
        var name:String?
        var code:Int?
        var items:[Item]
    }
    
    private var _data:[Category] = []
    
    private var _scrollView:UIScrollView = UIScrollView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setup()
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        if self.navigationController != nil && self.navigationController!.navigationBarHidden
        {
            self.navigationController!.navigationBarHidden = false
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if incrementProgressView != nil && incrementProgressView!.running
        {
            incrementProgressView!.reset()
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setup()
    {
        println("CommunityViewController init")
        
        self.view.backgroundColor = UIColor(white: 230 / 255, alpha: 1)
        
        var scrollViewY:CGFloat = AppConfig.shared().statusBarHeight + AppConfig.shared().navigationBarHeight
        _scrollView.frame = CGRectMake(0, scrollViewY, self.view.width, self.view.height - scrollViewY - AppConfig.shared().tabBarHeight)
        self.view.addSubview(_scrollView)
        
        loadData()
    }
    
    private func loadData()
    {
        var data:NSData?
        //先从缓存中加载
        var cacheDataPath:String = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as String
        cacheDataPath += "/forum_list.json"
        if NSFileManager.defaultManager().fileExistsAtPath(cacheDataPath)
        {
            println("先从缓存中加载")
            data = NSData(contentsOfFile: cacheDataPath)
        }
        if data != nil
        {
            parseData(data!)
            return
        }
        
        //缓存中没有，则从安装包中加载
        var bundlePath:String? = NSBundle.mainBundle().pathForResource("forum_list", ofType: "json")
        if bundlePath != nil
        {
            println("从安装包中加载")
            data = NSData(contentsOfFile: bundlePath!)
        }
        
        if data != nil
        {
            parseData(data!)
            NSFileManager.defaultManager().createFileAtPath(cacheDataPath, contents:data! ,attributes:nil)
            return
        }
        
        //缓存以及安装包中均没有，则在线加载
        loadDataRemote()
    }
    
    //加载商品列表
    private func loadDataRemote()
    {
        incrementProgressView?.start()
        var url:String = "http://open.qyer.com/qyer/bbs/forum_list?client_id=qyer_ios&client_secret=cd254439208ab658ddf9&v=1&track_user_id=2061877&track_deviceid=14F93361-1204-496C-8444-78059A841B4F&track_app_version=5.4.4&track_app_channel=App%20Store&track_device_info=iPhone%205s&track_os=ios%207.1.2&lat=35.716210&lon=139.786830&oauth_token=4de3ee300e936008c61f6b9c0f175257&app_installtime=1419754055"
        
        WebLoader.load(url, completionHandler: {(data:NSData!) in
        
            if data != nil
            {
                self.parseData(data!)
            }
            self.incrementProgressView?.finish()
        
            }, errorHandler: {(error:NSError) in
                
                self.incrementProgressView!.finish()
                
        })
    }
    
    //解析数据
    private func parseData(data:NSData)
    {
        let json = JSON(data: data)
        if let status = json["status"].integerValue
        {
            if status == 1
            {
                if let categories = json["data"].arrayValue
                {
                    for i in 0..<categories.count
                    {
                        var items:[Item] = []
                        if let group = categories[i]["group"].arrayValue
                        {
                            for j in 0..<group.count
                            {
                                items.append(Item(name: group[j]["name"].stringValue, code: group[j]["id"].integerValue, icon: group[j]["photo"].stringValue))
                            }
                        }
                        var categories:Category = Category(name: categories[i]["name"].stringValue, code: categories[i]["id"].integerValue, items: items)
                        _data.append(categories)
                    }
                }
                
                if _data.count > 0
                {
                    dispatch_async(dispatch_get_main_queue(),
                        {
                            self.updateView()
                    })
                }
                
                
            }
        }
    }
    
    private func updateView()
    {
        let lineColor:UIColor = UIColor(white: 200 / 255, alpha: 1)
        var lastSectionBottom:CGFloat = 0
        for i in 0..<_data.count
        {
            var category:Category = _data[i]
            
            var label:UILabel = UILabel()
            label.frame = CGRectMake(10, lastSectionBottom + 10, self.view.width, 20)
            label.font = UIFont.systemFontOfSize(16)
            label.textColor = UIColor.darkGrayColor()
            label.text = category.name
            _scrollView.addSubview(label)
            
            
            let cellHeight:CGFloat = 40
            let cellWidth:CGFloat = self.view.width * 0.5
            let numOfHorizontal:Int = 2
            var items:[Item] = category.items
            var numLine:Int = Int(ceil(CGFloat(items.count) / CGFloat(numOfHorizontal)))
            var sectionHeight:CGFloat = CGFloat(numLine) * cellHeight
            var sectionView:UIView = UIView()
            sectionView.layer.borderColor = lineColor.CGColor
            sectionView.layer.borderWidth = 0.5
            sectionView.backgroundColor = UIColor.whiteColor()
            sectionView.frame = CGRectMake(0, label.y + label.height + 10, self.view.width, sectionHeight)
            _scrollView.addSubview(sectionView)
            lastSectionBottom = sectionView.y + sectionView.height
            
            //画线
            var vSeparatorLine:UIView = UIView(frame: CGRectMake(cellWidth, 0, 0.5, sectionHeight))
            vSeparatorLine.backgroundColor = lineColor
            sectionView.addSubview(vSeparatorLine)
            
            for k in 1..<numLine
            {
                var hSeparatorLine:UIView = UIView(frame: CGRectMake(0, CGFloat(k) * cellHeight, sectionView.width, 0.5))
                hSeparatorLine.backgroundColor = lineColor
                sectionView.addSubview(hSeparatorLine)
            }
            
            //添加按钮
            for j in 0..<items.count
            {
                var item = items[j]
                var button:IndexButton = IndexButton()
                button.section = i
                button.row = j
                button.titleLabel?.font = UIFont.systemFontOfSize(14)
                button.titleLabel?.numberOfLines = 2
                button.titleLabel?.textAlignment = .Center
                button.setTitle(item.name, forState: .Normal)
                button.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
                button.addTarget(self, action: "buttonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
                var buttonX:CGFloat = CGFloat(j % numOfHorizontal) * cellWidth
                var buttonY:CGFloat = floor(CGFloat(j) / CGFloat(numOfHorizontal)) * cellHeight
                button.frame = CGRectMake(buttonX, buttonY, cellWidth, cellHeight)
                sectionView.addSubview(button)
            }
        }
        _scrollView.contentSize = CGSizeMake(self.view.width, lastSectionBottom + 40)
    }
    
    
    @objc private func buttonTapped(button:IndexButton)
    {
        var section:Int = button.section
        var row:Int = button.row
        if section >= 0 && section < _data.count && row >= 0 && row < _data[section].items.count
        {
            var item = _data[section].items[row]
            var forumID:Int? = item.code
            if forumID != nil
            {
                var infoTableViewController:InfoTableViewController = InfoTableViewController()
                infoTableViewController.title = _data[section].name
                infoTableViewController.forumID = forumID!
                self.navigationController?.pushViewController(infoTableViewController, animated: true)
            }
        }
        
    }
    
    
    
    
    
    
}