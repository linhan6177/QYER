//
//  CityTableViewController.swift
//  QYer
//
//  Created by linhan on 15-4-15.
//  Copyright (c) 2015年 linhan. All rights reserved.
//

import Foundation
import UIKit
class City:NSObject
{
    var id:String?
    var name:String?
    var englishName:String?
    var thumbURL:String?
    var lat:Double?
    var lng:Double?
    var popular:Bool = false
    //去过的人
    var beenNumber:Int = 0
    //经典景点
    var representative:String?
    var guide:Bool = true
}

class CityTableViewController: UITableViewController
{
    var countryID:String = ""
    private var _appearedFirstTime:Bool = false
    private var _cities:[City] = []
    //已经加载的页数
    private var _loadedPage:Int = 1
    
    private var _headerRefreshing:Bool = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if !_appearedFirstTime
        {
            _appearedFirstTime = true
            if countryID != ""
            {
                loadData()
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if incrementProgressView != nil && incrementProgressView!.running
        {
            incrementProgressView!.reset()
        }
    }
    
    private func setup()
    {
        self.title = "城市地区"
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.tableView.rowHeight = 80
        self.tableView.tableFooterView = UIView()
        
        setupRefresh()
    }
    
    
    
    func setupRefresh()
    {
        //上刷新取更多
        self.tableView.addFooterWithCallback({
            
            self._headerRefreshing = false
            self._loadedPage = self._loadedPage + 1
            self.loadData(page: self._loadedPage)
        })
    }
    
    private func endFreshing()
    {
        if _headerRefreshing
        {
            self.tableView.headerEndRefreshing()
        }
        else
        {
            self.tableView.footerEndRefreshing()
        }
    }
    
    //加载商品列表
    private func loadData(page:Int = 1)
    {
        incrementProgressView?.start()
        var url:String = "http://open.qyer.com/place/city/get_city_list?client_id=qyer_ios&client_secret=cd254439208ab658ddf9&v=1&track_user_id=2061877&track_deviceid=14F93361-1204-496C-8444-78059A841B4F&track_app_version=5.4.4&track_app_channel=App%20Store&track_device_info=iPhone%205s&track_os=ios%207.1.2&lat=22.554948&lon=113.925100&oauth_token=4de3ee300e936008c61f6b9c0f175257&app_installtime=1419754055&page=\(page)&countryid=\(countryID)&pageSize=20"
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
                if let cities = json["data"].arrayValue
                {
                    for i in 0..<cities.count
                    {
                        var city:City = City()
                        city.id = cities[i]["id"].stringValue
                        city.name = cities[i]["catename"].stringValue
                        city.englishName = cities[i]["catename_en"].stringValue
                        city.thumbURL = cities[i]["photo"].stringValue
                        city.lat = cities[i]["lat"].doubleValue
                        city.lng = cities[i]["lng"].doubleValue
                        city.popular = cities[i]["ishot"].boolValue ?? false
                        city.beenNumber = cities[i]["beennumber"].integerValue ?? 0
                        city.representative = cities[i]["representative"].stringValue
                        city.guide = cities[i]["isguide"].boolValue ?? true
                        _cities.append(city)
                    }
                }
                
                if _cities.count > 0
                {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tableView.reloadData()
                    
                    })
                }
            }
            
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return _cities.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell:CityCell? = tableView.dequeueReusableCellWithIdentifier("CityCell") as? CityCell
        if cell == nil
        {
            cell = CityCell(style: UITableViewCellStyle.Default, reuseIdentifier: "CityCell", cellWidth: self.view.width)
            println("create CityCell")
        }
        var index:Int = indexPath.row
        var label:String = ""
        if index >= 0 && index < _cities.count
        {
            cell!.city = _cities[index]
        }
        return cell!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        var index:Int = indexPath.row
        if index >= 0 && index < _cities.count
        {
            var cityDetailViewController:CityDetailViewController = CityDetailViewController()
            cityDetailViewController.cityID = _cities[index].id ?? ""
            cityDetailViewController.title = _cities[index].name ?? _cities[index].englishName
            self.navigationController!.pushViewController(cityDetailViewController, animated: true)
        }
    }
    
    
    
    
}