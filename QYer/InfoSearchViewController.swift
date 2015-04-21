//
//  InfoSearchViewController.swift
//  QYer
//
//  Created by linhan on 15-4-14.
//  Copyright (c) 2015年 linhan. All rights reserved.
//

import Foundation
import UIKit
class InfoSearchViewController: UIViewController,UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate
{
    private var _data:[Journal] = []
    //已经加载的页数
    private var _loadedPage:Int = 1
    
    private var _headerRefreshing:Bool = false
    
    private var _searchText:String = ""
    
    private var _searchBar:UISearchBar = UISearchBar()
    private var _tableView:UITableView?
    
    private var tableView:UITableView
        {
            if _tableView == nil
            {
                
                _tableView = UITableView()
                _tableView!.frame = self.view.frame
                _tableView!.hidden = true
                _tableView!.dataSource = self
                _tableView!.delegate = self
                _tableView!.tableFooterView = UIView()
                _tableView!.rowHeight = 80
                self.view.addSubview(_tableView!)
                
                
                
            }
            return _tableView!
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        if incrementProgressView != nil && incrementProgressView!.running
        {
            incrementProgressView!.reset()
        }
    }
    
    private func setup()
    {
        self.title = "搜索"
        self.view.backgroundColor = UIColor.whiteColor()
        
        if self.navigationController != nil
        {
            //进度条
            if self.incrementProgressView == nil
            {
                var progressView:IncrementProgressView = IncrementProgressView(frame: CGRectMake(0, AppConfig.shared().navigationBarHeight - 2, self.view.width, 2))
                self.navigationController!.navigationBar.addSubview(progressView)
            }
        }
        
        _searchBar.showsCancelButton = true
        //_searchBar.
        _searchBar.returnKeyType = UIReturnKeyType.Search
        _searchBar.placeholder = "搜索 游记攻略"
        _searchBar.delegate = self
        self.navigationItem.titleView = _searchBar
        
        setupRefresh()
    }
    
    func setupRefresh()
    {
        //上刷新取更多
        self.tableView.addFooterWithCallback({
            
            self._headerRefreshing = false
            self._loadedPage = self._loadedPage + 1
            self.searchText(self._searchText, page: self._loadedPage)
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
    
    private func searchText(text:String, page:Int = 1)
    {
        if text.length < 1 || page < 1
        {
            return
        }
        incrementProgressView?.start()
        var args:[NSObject:AnyObject] = ["count":20, "page":page, "track_user_id":"2061877", "track_deviceid":"14F93361-1204-496C-8444-78059A841B4F", "track_app_version":"5.4.4", "track_app_channel":"App Store", "track_device_info":"iphone 5s", "track_os":"ios 7.1.2", "lat":"22", "lon":"113", "oauth_token":"4de3ee300e936008c61f6b9c0f175257", "app_installtime":1419754055, "q":text]
        var url:String = "http://open.qyer.com/qyer/bbs/thread_search?client_id=qyer_ios&client_secret=cd254439208ab658ddf9"
        
        WebLoader.load(url, completionHandler: {(data:NSData!) in
            
            if(data != nil)
            {
                if page == 1
                {
                    self._data.removeAll()
                }
                self.parseData(data!)
                self.incrementProgressView?.finish()
                //self.displayLoadingView(false)
            }
            
            }, errorHandler: {(error:NSError) in
                
                self.incrementProgressView!.finish()
                //self.displayLoadingView(false)
            }, data:args, method:"POST")
    }
    
    //解析数据
    private func parseData(data:NSData)
    {
        let json = JSON(data: data)
        if let status = json["status"].integerValue
        {
            if status == 1
            {
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
                        self.tableView.hidden = false
                        self.tableView.reloadData()
                })
            }
        }
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar)
    {
        
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar)
    {
        if _searchBar.isFirstResponder()
        {
            _searchBar.resignFirstResponder()
        }
        
        self.dismissViewControllerAnimated(true, completion: {
            self._searchBar.text = ""
            self._data.removeAll()
            if self._tableView != nil
            {
                self._tableView!.hidden = true
            }
        })
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar)
    {
        if _searchBar.text.length > 0
        {
            //SearchHistory.shared().addRecord(_searchBar.text)
            _searchText = _searchBar.text
            searchText(_searchText)
        }
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
        if _searchBar.isFirstResponder()
        {
            _searchBar.resignFirstResponder()
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        var index:Int = indexPath.row
        if index >= 0 && index < _data.count
        {
            var detailViewController:JournalDetailViewController = JournalDetailViewController()
            detailViewController.viewURL = _data[index].viewURL
            self.navigationController!.pushViewController(detailViewController, animated: true)
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView)
    {
        if _searchBar.isFirstResponder()
        {
            _searchBar.resignFirstResponder()
        }
    }
    
    
}