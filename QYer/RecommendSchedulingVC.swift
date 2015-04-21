//
//  RecommendSchedulingVC.swift
//  QYer
//
//  Created by linhan on 15-4-17.
//  Copyright (c) 2015年 linhan. All rights reserved.
//

import Foundation
import UIKit

class Scheduling
{
    var id:String?
    var authorName:String?
    var title:String?
    var route:String?
    var coverURL:String?
    var avatarURL:String?
    var viewURL:String?
    var dayCount:Int?
}

class RecommendSchedulingVC: UIViewController,UITableViewDataSource,UITableViewDelegate
{
    var id:String = ""
    var type:POIType = POIType.City
    
    private let RecommendTypes:[[String:String]] = [["name":"编辑推荐", "type":"editor"], ["name":"用户精选", "type":"user"]]
    private var _recommendType:String = ""
    
    private var _schedulings:[String:[Scheduling]] = Dictionary()
    
    private var _appearedFirstTime:Bool = false
    
    //已经加载的页数
    private var _loadedPage:Int = 1
    
    private var _headerRefreshing:Bool = false
    
    lazy private var _tableView:UITableView = UITableView()
    private var _segmentedControl:UISegmentedControl?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setup()
    }
    
    private func setup()
    {
        self.title = "推荐行程"
        self.view.backgroundColor = UIColor(white: 230 / 250, alpha: 1)
        
        var items:[String] = []
        for i in 0..<RecommendTypes.count
        {
            items.append(RecommendTypes[i]["name"]!)
            _schedulings[RecommendTypes[i]["type"]!] = []
        }
        _recommendType = RecommendTypes[0]["type"]!
        let SegmentedControlY:CGFloat = AppConfig.shared().statusBarHeight + AppConfig.shared().navigationBarHeight + 5
        _segmentedControl = UISegmentedControl(items: items)
        _segmentedControl!.selectedSegmentIndex = 0
        _segmentedControl!.frame = CGRectMake((self.view.width - 150) * 0.5, SegmentedControlY, 150, 30)
        _segmentedControl!.addTarget(self, action:"segmentedControlChanged:", forControlEvents:UIControlEvents.ValueChanged)
        self.view.addSubview(_segmentedControl!)
        
        let tableViewY:CGFloat = _segmentedControl!.bottom + 5
        _tableView.backgroundColor = UIColor.clearColor()
        _tableView.rowHeight = 200
        _tableView.separatorStyle = .None
        _tableView.frame = CGRectMake(0, tableViewY, self.view.width, self.view.height - tableViewY)
        _tableView.dataSource = self
        _tableView.delegate = self
        _tableView.tableFooterView = UIView()
        self.view.addSubview(_tableView)
        
        setupRefresh()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if incrementProgressView != nil && incrementProgressView!.running
        {
            incrementProgressView!.reset()
        }
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        if id != "" && !_appearedFirstTime
        {
            _appearedFirstTime = true
            loadData()
        }
    }
    
    private func setupRefresh()
    {
        //上刷新取更多
        self._tableView.addFooterWithCallback({
            
            self._headerRefreshing = false
            self._loadedPage = self._loadedPage + 1
            self.loadData(page: self._loadedPage)
        })
    }
    
    private func endFreshing()
    {
        if _headerRefreshing
        {
            self._tableView.headerEndRefreshing()
        }
        else
        {
            self._tableView.footerEndRefreshing()
        }
    }
    
    //加载商品列表
    private func loadData(page:Int = 1)
    {
        incrementProgressView?.start()
        var url:String = "http://open.qyer.com/place/common/get_recommend_plan_list?client_id=qyer_ios&client_secret=cd254439208ab658ddf9&v=1&track_user_id=2061877&track_deviceid=14F93361-1204-496C-8444-78059A841B4F&track_app_version=5.4.4&track_app_channel=App%20Store&track_device_info=iPhone%205s&track_os=ios%207.1.2&lat=22.555020&lon=113.925114&oauth_token=4de3ee300e936008c61f6b9c0f175257&app_installtime=1419754055&type=city&pagesize=10&page=\(page)&recommand=\(_recommendType)&screensize=640&cityid=\(id)"
        if type == .Country
        {
            url = "http://open.qyer.com/place/common/get_recommend_plan_list?client_id=qyer_ios&client_secret=cd254439208ab658ddf9&v=1&track_user_id=2061877&track_deviceid=14F93361-1204-496C-8444-78059A841B4F&track_app_version=5.4.4&track_app_channel=App%20Store&track_device_info=iPhone%205s&track_os=ios%207.1.2&lat=22.555020&lon=113.925114&oauth_token=4de3ee300e936008c61f6b9c0f175257&app_installtime=1419754055&type=country&pagesize=10&page=\(page)&recommand=\(_recommendType)&countryid=\(id)&screensize=640"
        }
        
        
        WebLoader.load(url, completionHandler: {(data:NSData!) in
            
            if(data != nil)
            {
                self.parseData(data!)
                self.incrementProgressView?.finish()
                self.endFreshing()
                //self.displayLoadingView(false)
            }
            
            }, errorHandler: {(error:NSError) in
                
                self.incrementProgressView?.finish()
                self.endFreshing()
                //self.displayLoadingView(false)
        })
    }
    
    //解析信息
    private func parseData(data:NSData)
    {
        let json = JSON(data: data)
        if let status = json["status"].integerValue
        {
            if status == 1
            {
                if let schedulings = json["data"].arrayValue
                {
                    var storedSchedulings:[Scheduling]? = _schedulings[_recommendType]
                    for i in 0..<schedulings.count
                    {
                        var scheduling:Scheduling = Scheduling()
                        scheduling.id = schedulings[i]["id"].stringValue
                        scheduling.authorName = schedulings[i]["username"].stringValue
                        scheduling.title = schedulings[i]["subject"].stringValue
                        scheduling.route = schedulings[i]["route"].stringValue
                        scheduling.coverURL = schedulings[i]["photo"].stringValue
                        scheduling.avatarURL = schedulings[i]["avatar"].stringValue
                        scheduling.viewURL = schedulings[i]["view_url"].stringValue
                        scheduling.dayCount = schedulings[i]["day_count"].stringValue != nil ? (schedulings[i]["day_count"].stringValue! as NSString).integerValue : 0
                        
                        storedSchedulings?.append(scheduling)
                    }
                    _schedulings[_recommendType] = storedSchedulings
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self._tableView.reloadData()
                })
            }
            
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        var schedulings:[Scheduling]? = _schedulings[_recommendType]
        return schedulings != nil ? schedulings!.count : 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell:RecommendSchedulingCell? = tableView.dequeueReusableCellWithIdentifier("RecommendSchedulingCell") as? RecommendSchedulingCell
        if cell == nil
        {
            cell = RecommendSchedulingCell(style: UITableViewCellStyle.Default, reuseIdentifier: "RecommendSchedulingCell", cellWidth: self.view.width)
            println("create RecommendSchedulingCell")
        }
        var index:Int = indexPath.row
        var schedulings:[Scheduling]? = _schedulings[_recommendType]
        if schedulings != nil && index >= 0 && index < schedulings!.count
        {
            cell!.data = schedulings![index]
        }
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        var index:Int = indexPath.row
        var schedulings:[Scheduling]? = _schedulings[_recommendType]
        if schedulings != nil && index >= 0 && index < schedulings!.count
        {
            var viewURL:String? = schedulings![index].viewURL
            if viewURL != nil && viewURL! != ""
            {
                var webViewController:WebViewController = WebViewController()
                webViewController.viewURL = viewURL!
                webViewController.autoTitleAfterLoadedFinish = false
                webViewController.title = schedulings![index].title
                self.navigationController!.pushViewController(webViewController, animated: true)
            }
        }
    }
    
    @objc private func segmentedControlChanged(segmentedControl:UISegmentedControl)
    {
        var index:Int = segmentedControl.selectedSegmentIndex
        if index >= 0 && index < RecommendTypes.count
        {
            _recommendType = RecommendTypes[index]["type"]!
            var schedulings:[Scheduling]? = _schedulings[_recommendType]
            if schedulings == nil || schedulings!.count == 0
            {
                loadData()
            }
            else
            {
                self._tableView.reloadData()
            }
            self._tableView.contentOffset = CGPointZero
        }
        
    }
    
    
}