//
//  InfoSearchViewController.swift
//  QYer
//
//  Created by linhan on 15-4-14.
//  Copyright (c) 2015年 linhan. All rights reserved.
//

import Foundation
import UIKit

enum POIType:Int
{
    case Country
    case City
    case Position
}

class POISearchData:NSObject
{
    var id:String?
    var name:String?
    var beenCount:Int?
    var parentName:String?
    var parentParentName:String?
    var type:POIType?
    var typeLabel:String?
    var thumbURL:String?
}

class DestinationSearchViewController: UIViewController,UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate
{
    private var _data:[POISearchData] = []
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
        _searchBar.placeholder = "搜索 国家、城市、目的地"
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
        
        var args:[NSObject:AnyObject] = ["track_user_id":"2061877", "track_deviceid":"14F93361-1204-496C-8444-78059A841B4F", "track_app_version":"5.4.4", "track_app_channel":"App Store", "track_device_info":"iphone 5s", "track_os":"ios 7.1.2", "lat":"22", "lon":"113", "oauth_token":"4de3ee300e936008c61f6b9c0f175257", "app_installtime":1419754055, "page":page, "keyword":text]
        var url:String = "http://open.qyer.com/place/poi/get_srearch_list?client_id=qyer_ios&client_secret=cd254439208ab658ddf9"
        
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
                if let places = json["data"].arrayValue
                {
                    for i in 0..<places.count
                    {
                        var data:POISearchData = POISearchData()
                        data.id = places[i]["id"].stringValue
                        data.name = places[i]["poiname"].stringValue
                        data.parentName = places[i]["parentname"].stringValue
                        data.parentParentName = places[i]["parent_parentname"].stringValue
                        data.typeLabel = places[i]["label"].stringValue
                        data.thumbURL = places[i]["photo"].stringValue
                        data.beenCount = places[i]["beennumber"].stringValue != nil ? (places[i]["beennumber"].stringValue! as NSString).integerValue : 0
                        var type:Int = places[i]["type"].integerValue ?? 0
                        if type == 1
                        {
                            data.type = POIType.Position
                        }
                        else if type == 2
                        {
                            data.type = POIType.City
                        }
                        else if type == 3
                        {
                            data.type = POIType.Country
                        }
                        _data.append(data)
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
        var cell:DestinationSearchCell? = tableView.dequeueReusableCellWithIdentifier("DestinationSearchCell") as? DestinationSearchCell
        if cell == nil
        {
            cell = DestinationSearchCell(style: UITableViewCellStyle.Default, reuseIdentifier: "DestinationSearchCell", cellWidth: self.view.width)
            println("create DestinationSearchCell")
        }
        var index:Int = indexPath.row
        var label:String = ""
        if index >= 0 && index < _data.count
        {
            cell!.data = _data[index]
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
            var data:POISearchData = _data[index]
            var id:String = data.id ?? ""
            var type:POIType? = data.type
            if id != "" && type != nil
            {
                var detailViewController:UIViewController?
                if type == .Country
                {
                    detailViewController = CountryProfileViewController()
                    detailViewController?.title = data.name
                    (detailViewController as CountryProfileViewController).countryID = id
                }
                else if type == .City
                {
                    detailViewController = CityDetailViewController()
                    detailViewController?.title = data.name
                    (detailViewController as CityDetailViewController).cityID = id
                }
                else if type == .Position
                {
                    detailViewController = POIDetailViewController()
                    (detailViewController as POIDetailViewController).id = id
                }
                
                if detailViewController != nil
                {
                    self.navigationController?.pushViewController(detailViewController!, animated: true)
                }
            }
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