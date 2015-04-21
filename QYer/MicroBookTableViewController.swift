//
//  EssenceJournalViewController.swift
//  QYer
//
//  Created by linhan on 15-4-16.
//  Copyright (c) 2015年 linhan. All rights reserved.
//

import Foundation
import UIKit

class MicroBookTableViewController: UITableViewController
{
    var type:POIType = POIType.City
    var id:String = ""
    
    private var _journals:[Journal] = []
    
    private var _appearedFirstTime:Bool = false
    
    //已经加载的页数
    private var _loadedPage:Int = 1
    
    private var _headerRefreshing:Bool = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setup()
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
    
    private func setup()
    {
        self.title = "微锦囊"
        self.view.backgroundColor = UIColor(white: 230 / 250, alpha: 1)
        
        tableView.rowHeight = 270
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .None
        setupRefresh()
    }
    
    private func setupRefresh()
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
        var url:String = "http://open.qyer.com/qyer/footprint/mguide_list?client_id=qyer_ios&client_secret=cd254439208ab658ddf9&v=1&track_user_id=2061877&track_deviceid=14F93361-1204-496C-8444-78059A841B4F&track_app_version=5.4.4&track_app_channel=App%20Store&track_device_info=iPhone%205s&track_os=ios%207.1.2&lat=22.555020&lon=113.925114&oauth_token=4de3ee300e936008c61f6b9c0f175257&app_installtime=1419754055&type=city&id=\(id)&page=\(page)&count=10"
        if type == .Country
        {
            url = "http://open.qyer.com/qyer/footprint/mguide_list?client_id=qyer_ios&client_secret=cd254439208ab658ddf9&v=1&track_user_id=2061877&track_deviceid=14F93361-1204-496C-8444-78059A841B4F&track_app_version=5.4.4&track_app_channel=App%20Store&track_device_info=iPhone%205s&track_os=ios%207.1.2&lat=22.555020&lon=113.925114&oauth_token=4de3ee300e936008c61f6b9c0f175257&app_installtime=1419754055&type=country&id=\(id)&page=\(page)&count=10"
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
                if let trips = json["data"].arrayValue
                {
                    for i in 0..<trips.count
                    {
                        var journal:Journal = Journal()
                        journal.id = trips[i]["id"].stringValue ?? ""
                        journal.name = trips[i]["username"].stringValue ?? ""
                        journal.title = trips[i]["title"].stringValue ?? ""
                        journal.thumbURL = trips[i]["photo"].stringValue ?? ""
                        journal.avatarURL = trips[i]["avatar"].stringValue ?? ""
                        journal.caption = trips[i]["description"].stringValue ?? ""
                        journal.placeCount = trips[i]["count"].stringValue != nil ? (trips[i]["count"].stringValue! as NSString).integerValue : nil
                        self._journals.append(journal)
                    }
                    
                    if self._journals.count > 0
                    {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.tableView.reloadData()
                        })
                    }
                    
                }
            }
            
        }//end status
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return _journals.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell:MicroBookCell? = tableView.dequeueReusableCellWithIdentifier("MicroBookCell") as? MicroBookCell
        if cell == nil
        {
            cell = MicroBookCell(style: UITableViewCellStyle.Default, reuseIdentifier: "MicroBookCell", cellWidth: self.view.width)
            println("create MicroBookCell")
        }
        var index:Int = indexPath.row
        var label:String = ""
        if index >= 0 && index < _journals.count
        {
            cell!.journal = _journals[index]
        }
        return cell!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        var index:Int = indexPath.row
        if index >= 0 && index < _journals.count
        {
            var id:String? = _journals[index].id
            if id != nil && id! != ""
            {
                var detailViewController:MicroBookDetailViewController = MicroBookDetailViewController()
                detailViewController.id = id!
                detailViewController.title = _journals[index].title
                self.navigationController!.pushViewController(detailViewController, animated: true)
            }
            
        }
    }
    
    
    
    
}