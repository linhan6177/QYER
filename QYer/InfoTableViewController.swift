//
//  InfoTableViewController.swift
//  QYer
//
//  Created by linhan on 15-4-10.
//  Copyright (c) 2015年 linhan. All rights reserved.
//

import Foundation
import UIKit
class InfoTableViewController: UIViewController,UITableViewDataSource,UITableViewDelegate
{
    var forumID:Int = -1
    
    private let TableViewCellHeight:CGFloat = 80
    
    private var _type:String = "all"
    
    private var _sortType:[[String:String]] = [["name":"全部", "type":"all"], ["name":"最新", "type":"new"], ["name":"精华", "type":"digest"]]
    
    private var _data:[Journal] = []
    //已经加载的页数
    private var _loadedPage:Int = 1
    
    private var _headerRefreshing:Bool = false
    
    private var _headerView:UIView = UIView()
    private var _nameLabel:UILabel = UILabel()
    private var _avatarView:ImageLoader?
    private var _countLable:UILabel = UILabel()
    
    
    private var _segmentedControl:UISegmentedControl?
    
    private var _tableView:UITableView = UITableView()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if incrementProgressView != nil && incrementProgressView!.running
        {
            incrementProgressView!.reset()
        }
    }
    
    private func setup()
    {
        self.view.backgroundColor = UIColor.whiteColor()
        //self.navigationController?.navigationBar.translucent = false
        
        _headerView.frame = CGRectMake(0, 0, self.view.width, 70)
        _headerView.backgroundColor = UIColor.whiteColor()
        _avatarView = ImageLoader(frame: CGRectMake(10, 10, 55, 55))
        _headerView.addSubview(_avatarView!)
        var nameLabelX:CGFloat = _avatarView!.x + _avatarView!.width + 10
        _nameLabel.frame = CGRectMake(nameLabelX, 10, self.view.width - nameLabelX - 10, 20)
        _headerView.addSubview(_nameLabel)
        _countLable.frame = CGRectMake(nameLabelX, 45, self.view.width - nameLabelX - 10, 20)
        _headerView.addSubview(_countLable)
        var hSeparatorLine1:UIView = UIView(frame: CGRectMake(0, _headerView.height - 3, _headerView.width, 0.5))
        hSeparatorLine1.backgroundColor = UIColor(white: 200 / 255, alpha: 1)
        _headerView.addSubview(hSeparatorLine1)
        
        _type = _sortType[0]["type"]!
        var segmentedItems:[String] = []
        for i in 0..<_sortType.count
        {
            segmentedItems.append(_sortType[i]["name"]!)
        }
        _segmentedControl = UISegmentedControl(items: segmentedItems)
        _segmentedControl!.backgroundColor = UIColor.whiteColor()
        _segmentedControl!.selectedSegmentIndex = 0
        _segmentedControl!.frame = CGRectMake(0, 0, self.view.width, 30)
        _segmentedControl!.addTarget(self, action:"segmentedControlChanged:", forControlEvents:UIControlEvents.ValueChanged)
        
        _tableView.frame = CGRectMake(0, 0, self.view.width, self.view.height)
        self._tableView.rowHeight = TableViewCellHeight
        self._tableView.tableHeaderView = _headerView
        self._tableView.tableFooterView = UIView()
        self._tableView.dataSource = self
        self._tableView.delegate = self
        self.view.addSubview(_tableView)
        
        setupRefresh()
        
        if forumID != -1
        {
            loadData()
        }
    }
    
    func setupRefresh()
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
    
    //加载列表
    private func loadData(page:Int = 1)
    {
        incrementProgressView?.start()
        var url:String = "http://open.qyer.com/qyer/bbs/forum_thread_list?client_id=qyer_ios&client_secret=cd254439208ab658ddf9&v=1&track_user_id=2061877&track_deviceid=14F93361-1204-496C-8444-78059A841B4F&track_app_version=5.4.4&track_app_channel=App%20Store&track_device_info=iPhone%205s&track_os=ios%207.1.2&lat=35.716210&lon=139.786830&oauth_token=4de3ee300e936008c61f6b9c0f175257&app_installtime=1419754055&type=\(_type)&count=10&forum_id=\(forumID)&page=\(page)&delcache=1"
        WebLoader.load(url, completionHandler: {(data:NSData!) in
            
            if data != nil
            {
                self.parseData(data!)
            }
            self.incrementProgressView?.finish()
            self.endFreshing()
            
            }, errorHandler: {(error:NSError) in
                
                self.incrementProgressView?.finish()
                self.endFreshing()
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
                var total:Int = json["data"]["total"].integerValue ?? 0
                var title:String = json["data"]["name"].stringValue ?? ""
                var avatarURL:String? = json["data"]["photo"].stringValue
                var formatter:NSDateFormatter = NSDateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                if let journales = json["data"]["entry"].arrayValue
                {
                    for i in 0..<journales.count
                    {
                        var journal:Journal = Journal()
                        journal.name = journales[i]["username"].stringValue
                        journal.title = journales[i]["title"].stringValue
                        journal.thumbURL = journales[i]["photo"].stringValue
                        journal.viewURL = journales[i]["view_url"].stringValue
                        var lastPost:NSString? = journales[i]["lastpost"].stringValue
                        if lastPost != nil
                        {
                            var date:NSDate = NSDate(timeIntervalSince1970: lastPost!.doubleValue)
                            journal.date = formatter.stringFromDate(date)
                        }
                        _data.append(journal)
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(),
                    {
                        self._nameLabel.text = title
                        self._countLable.text = String(total) + "个帖子"
                        if avatarURL != nil
                        {
                            self._avatarView?.load(avatarURL!)
                        }
                        self._tableView.reloadData()
                })
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return _segmentedControl != nil ? _segmentedControl!.height : 0
        //return 0
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        //return nil
        return _segmentedControl
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return _data.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell:JournalCell? = tableView.dequeueReusableCellWithIdentifier("journalCell") as? JournalCell
        if cell == nil
        {
            cell = JournalCell(style: UITableViewCellStyle.Default, reuseIdentifier: "journalCell", cellWidth: self.view.width)
            println("create JournalCell")
        }
        var index:Int = indexPath.row
        var label:String = ""
        if index >= 0 && index < _data.count
        {
            cell!.journal = _data[index]
        }
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        var index:Int = indexPath.row
        if index >= 0 && index < _data.count
        {
            var detailViewController:JournalDetailViewController = JournalDetailViewController()
            detailViewController.viewURL = _data[index].viewURL
            self.navigationController!.pushViewController(detailViewController, animated: true)
        }
    }
    
    
    
    @objc private func segmentedControlChanged(segmentedControl:UISegmentedControl)
    {
        var index:Int = segmentedControl.selectedSegmentIndex
        if index >= 0 && index < _sortType.count
        {
            _type = _sortType[index]["type"]!
            _data.removeAll()
            self._tableView.contentOffset = CGPointZero
            loadData()
        }
        
    }
    
    
}