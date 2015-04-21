//
//  TravelPlaceListViewController.swift
//  QYer
//
//  Created by linhan on 15-4-18.
//  Copyright (c) 2015年 linhan. All rights reserved.
//

import Foundation
import UIKit
class Place
{
    var id:String?
    var name:String?
    var thumbURL:String?
    var beenCount:Int?
    var rank:Int?
    var lat:Double?
    var lng:Double?
    var mguide:Bool?
}
class TravelPlaceListViewController: UIViewController,UITableViewDataSource,UITableViewDelegate
{
    var id:String = ""
    
    private let Types:[[String:String]] = [["name":"景点", "type":"32"], ["name":"美食", "type":"78"], ["name":"购物", "type":"174"], ["name":"活动", "type":"148"]]
    var type:String = ""
    
    private var _places:[String:[Place]] = Dictionary()
    
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
        self.title = "旅游地"
        self.view.backgroundColor = UIColor.whiteColor()
        
        var items:[String] = []
        var selectedIndex:Int = 0
        for i in 0..<Types.count
        {
            items.append(Types[i]["name"]!)
            _places[Types[i]["type"]!] = []
            if type != "" && Types[i]["type"]! == type
            {
                selectedIndex = i
            }
        }
        if type == ""
        {
            type = Types[0]["type"]!
        }
        
        let SegmentedControlY:CGFloat = AppConfig.shared().statusBarHeight + AppConfig.shared().navigationBarHeight + 5
        _segmentedControl = UISegmentedControl(items: items)
        _segmentedControl!.selectedSegmentIndex = selectedIndex
        _segmentedControl!.frame = CGRectMake(10, SegmentedControlY, self.view.width - 20, 30)
        _segmentedControl!.addTarget(self, action:"segmentedControlChanged:", forControlEvents:UIControlEvents.ValueChanged)
        self.view.addSubview(_segmentedControl!)
        
        let tableViewY:CGFloat = _segmentedControl!.bottom + 5
        _tableView.rowHeight = 80
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
        var url:String = "http://open.qyer.com/qyer/footprint/poi_list?client_id=qyer_ios&client_secret=cd254439208ab658ddf9&v=1&track_user_id=2061877&track_deviceid=14F93361-1204-496C-8444-78059A841B4F&track_app_version=5.4.4&track_app_channel=App%20Store&track_device_info=iPhone%205s&track_os=ios%207.1.2&oauth_token=4de3ee300e936008c61f6b9c0f175257&app_installtime=1419754055&city_id=\(id)&count=20&category_id=\(type)&page=1"
        
        
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
                if let places = json["data"].arrayValue
                {
                    var storedPlaces:[Place]? = _places[type]
                    for i in 0..<places.count
                    {
                        var id:String?
                        var name:String?
                        var thumbURL:String?
                        var beenCount:Int?
                        var rank:Int?
                        var lat:Double?
                        var lng:Double?
                        var mguide:Bool?
                        
                        var place:Place = Place()
                        place.id = places[i]["id"].stringValue
                        place.name = places[i]["chinesename"].stringValue ?? places[i]["englishname"].stringValue ?? places[i]["localname"].stringValue
                        place.thumbURL = places[i]["photo"].stringValue
                        place.beenCount = places[i]["beennumber"].integerValue
                        place.rank = places[i]["grade"].integerValue
                        place.lat = places[i]["lat"].stringValue != nil ? (places[i]["lat"].stringValue! as NSString).doubleValue : nil
                        place.lng = places[i]["lng"].stringValue != nil ? (places[i]["lng"].stringValue! as NSString).doubleValue : nil
                        place.mguide = places[i]["has_mguide"].boolValue
                        
                        storedPlaces?.append(place)
                    }
                    _places[type] = storedPlaces
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self._tableView.reloadData()
                })
            }
            
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        var places:[Place]? = _places[type]
        return places != nil ? places!.count : 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell:TravelPlaceCell? = tableView.dequeueReusableCellWithIdentifier("TravelPlaceCell") as? TravelPlaceCell
        if cell == nil
        {
            cell = TravelPlaceCell(style: UITableViewCellStyle.Default, reuseIdentifier: "TravelPlaceCell", cellWidth: self.view.width)
            println("create TravelPlaceCell")
        }
        var index:Int = indexPath.row
        var places:[Place]? = _places[type]
        if places != nil && index >= 0 && index < places!.count
        {
            cell!.data = places![index]
        }
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        var index:Int = indexPath.row
        var places:[Place]? = _places[type]
        if places != nil && index >= 0 && index < places!.count
        {
            var placeID:String? = places![index].id
            if placeID != nil && placeID! != ""
            {
                var detailViewController:POIDetailViewController = POIDetailViewController()
                detailViewController.id = placeID!
                self.navigationController!.pushViewController(detailViewController, animated: true)
            }
        }
    }
    
    @objc private func segmentedControlChanged(segmentedControl:UISegmentedControl)
    {
        var index:Int = segmentedControl.selectedSegmentIndex
        if index >= 0 && index < Types.count
        {
            type = Types[index]["type"]!
            var places:[Place]? = _places[type]
            if places == nil || places!.count == 0
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