//
//  RebateViewController.swift
//  QYer
//
//  Created by linhan on 15-4-6.
//  Copyright (c) 2015年 linhan. All rights reserved.
//

import UIKit

struct RebateItem
{
    var coverURL:String?
    var caption:String?
    var price:String?
    var endDate:String?
    var discount:String?
    var viewURL:String?
    var id:String?
}

class RebateViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate
{
    private var _appearedFirstTime:Bool = false
    private var _headerRefreshing:Bool = false
    
    private var _items:[RebateItem] = []
    
    private var _collectionView:UICollectionView?
    
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
        
        if !_appearedFirstTime
        {
            _appearedFirstTime = true
            loadData()
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
        println("RebateViewController init")
        self.view.backgroundColor = UIColor.whiteColor()
        
        var testView:UIView = UIView()
        //self.view.addSubview(testView)
        self.automaticallyAdjustsScrollViewInsets = false
        
        let PullDownBtnY:CGFloat = AppConfig.shared().statusBarHeight + AppConfig.shared().navigationBarHeight + 10
        let PullDownBtnHeight:CGFloat = 30
        var offsetY:CGFloat = PullDownBtnY + PullDownBtnHeight
        //offsetY += 30
        
        var PullDownBtnBGView:UIView = UIView()
        PullDownBtnBGView.frame = CGRectMake(0, PullDownBtnY, self.view.width, PullDownBtnHeight)
        PullDownBtnBGView.layer.borderColor = UIColor(white: 200 / 255, alpha: 1).CGColor
        PullDownBtnBGView.layer.borderWidth = 0.5
        PullDownBtnBGView.backgroundColor = UIColor.whiteColor()
        //self.view.addSubview(PullDownBtnBGView)
        
        var titleFont:UIFont = UIFont.systemFontOfSize(14)
        
        var typeList:PullDownListView = PullDownListView(frame: CGRectMake(0, 0, 0, 0))
        //typeList.backgroundColor = UIColor.lightGrayColor()
        typeList.titleLabel.font = titleFont
        typeList.title = "折扣类型"
        typeList.items = ["全部类型", "欧铁票", "当地游", "机票", "酒店", "自由行", "游轮", "租车", "保险", "签证"]
        typeList.modelRect = CGRectMake(0, 0, self.view.width, self.view.height - 0)
        typeList.contentOffsetY = offsetY
        typeList.frame = CGRectMake(0, PullDownBtnY, typeList.width, typeList.height)
        self.view.addSubview(typeList)
        
        var departureList:PullDownListView = PullDownListView(frame: CGRectMake(0, 0, 0, 0))
        //departureList.backgroundColor = UIColor.darkGrayColor()
        departureList.titleLabel.font = titleFont
        departureList.title = "出发地"
        departureList.items = ["全部出发地", "北京/天津", "上海/杭州", "成都/重庆", "广州/深圳", "港澳台", "国内其他", "海外"]
        departureList.modelRect = CGRectMake(0, 0, self.view.width, self.view.height - 0)
        departureList.contentOffsetY = offsetY
        departureList.frame = CGRectMake(self.view.width * 0.25, PullDownBtnY, departureList.width, departureList.height)
        self.view.addSubview(departureList)
        
        var destinationList:PullDownListView = PullDownListView(frame: CGRectMake(0, 0, 0, 0))
        destinationList.titleLabel.font = titleFont
        destinationList.title = "目的地"
        destinationList.items = ["全部目的地", "香港", "澳门", "台湾", "泰国", "马来西亚", "法国", "意大利", "新加坡", "美国", "日本", "德国", "韩国"]
        destinationList.modelRect = CGRectMake(0, 0, self.view.width, self.view.height - 0)
        destinationList.contentOffsetY = offsetY
        destinationList.frame = CGRectMake(self.view.width * 0.5, PullDownBtnY, destinationList.width, destinationList.height)
        self.view.addSubview(destinationList)
        
        var dateList:PullDownListView = PullDownListView(frame: CGRectMake(0, 0, 0, 0))
        dateList.titleLabel.font = titleFont
        dateList.title = "旅行时间"
        dateList.items = ["全部时间", "一个月内", "1-3个月内", "3-6个月内", "6个月以后", "新年", "春节", "清明", "劳动", "端午", "中秋", "国庆"]
        dateList.modelRect = CGRectMake(0, 0, self.view.width, self.view.height - 0)
        dateList.contentOffsetY = offsetY
        dateList.frame = CGRectMake(self.view.width * 0.75, PullDownBtnY, dateList.width, dateList.height)
        self.view.addSubview(dateList)
        
        
        let numOfHorizontal:Int = 2
        let Grid:CGFloat = 10
        var cellWidth:CGFloat = (self.view.width - (CGFloat(numOfHorizontal + 1) * Grid)) / CGFloat(numOfHorizontal)
        var layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSizeMake(cellWidth, 150);
        //横向最小间隔
        layout.minimumInteritemSpacing = Grid;
        //纵向最小间隔
        layout.minimumLineSpacing = Grid;
        layout.sectionInset = UIEdgeInsetsMake(Grid, Grid, Grid, Grid)
        
        let TableViewY:CGFloat = PullDownBtnBGView.bottom + 5
        _collectionView = UICollectionView(frame: CGRectMake(0, TableViewY, self.view.width, self.view.height - TableViewY - AppConfig.shared().tabBarHeight), collectionViewLayout: layout)
        _collectionView!.backgroundColor = UIColor(white: 230 / 250, alpha: 1)
        _collectionView!.registerClass(RebateCell.self, forCellWithReuseIdentifier: "CostomCollectionViewCell")
        _collectionView!.dataSource = self
        _collectionView!.delegate = self
        self.view.addSubview(_collectionView!)
        setupRefresh()
    }
    
    func setupRefresh()
    {
        //上刷新取更多
        
        self._collectionView!.addFooterWithCallback({
            
            self._headerRefreshing = false
            var maxID:String = self._items.count > 0 ? self._items.last!.id ?? "0" : "0"
            self.loadData(maxID: maxID)
            
        })
    }
    
    private func endFreshing()
    {
        if _headerRefreshing
        {
            self._collectionView!.headerEndRefreshing()
        }
        else
        {
            self._collectionView!.footerEndRefreshing()
        }
    }
    
    private func test()
    {
        
    }
    
    //加载商品列表
    private func loadData(maxID:String = "0")
    {
        dispatch_async(dispatch_get_main_queue(),
            {
                self.test()
                self.incrementProgressView?.start()
        })
        
        var url:String = "http://open.qyer.com/lastminute/get_lastminute_list?client_id=qyer_ios&client_secret=cd254439208ab658ddf9&v=1&track_user_id=2061877&track_deviceid=14F93361-1204-496C-8444-78059A841B4F&track_app_version=5.4.4&track_app_channel=App%20Store&track_device_info=iPhone%205s&track_os=ios%207.1.2&lat=35.716210&lon=139.786830&oauth_token=4de3ee300e936008c61f6b9c0f175257&app_installtime=1419754055&page_size=20&is_show_pay=1&country_id=0&continent_id=0&max_id=\(maxID)&times=&product_type=0"
        
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
                if let items = json["data"].arrayValue
                {
                    for i in 0..<items.count
                    {
                        var item:RebateItem = RebateItem(coverURL: items[i]["pic"].stringValue, caption: items[i]["title"].stringValue, price: items[i]["buy_price"].stringValue, endDate: items[i]["end_date"].stringValue, discount: items[i]["lastminute_des"].stringValue, viewURL: items[i]["url"].stringValue, id: items[i]["id"].stringValue)
                        
                        _items.append(item)
                    }
                }
                
                if _items.count > 0
                {
                    dispatch_async(dispatch_get_main_queue(),
                        {
                            self._collectionView!.reloadData()
                    })
                }
                
            }//end status
            
        }
        
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return _items.count
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        var cell:RebateCell = collectionView.dequeueReusableCellWithReuseIdentifier("CostomCollectionViewCell", forIndexPath: indexPath) as RebateCell
        var index:Int = indexPath.row
        if index >= 0 && index < _items.count
        {
            var item:RebateItem = _items[index]
            cell.item = item
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        var index:Int = indexPath.row
        if index >= 0 && index < _items.count
        {
            var item:RebateItem = _items[index]
            var detailViewController:JournalDetailViewController = JournalDetailViewController()
            detailViewController.viewURL = item.viewURL
            self.navigationController!.pushViewController(detailViewController, animated: true)
            
        }
    }
    
    
    
    
    
    
    
    
}//end class