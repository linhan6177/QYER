//
//  CountryProfileViewController.swift
//  QYer
//
//  Created by linhan on 15-4-9.
//  Copyright (c) 2015年 linhan. All rights reserved.
//

import Foundation
import UIKit
class CountryProfileViewController: UIViewController,UITableViewDataSource,UITableViewDelegate
{
    private var _appearedFirstTime:Bool = false
    private var _countryID:String = ""
    var countryID:String
    {
        get
        {
            return _countryID
        }
        set
        {
            _countryID = newValue
            
        }
    }
    
    private let TableViewCellHeight:CGFloat = 80
    
    private var _journals:[Journal] = []
    
    private var _overviewURL:String?
    
    private var _cityCells:[SimpleCityCell] = []
    
    private var _scrollView:UIScrollView = UIScrollView()
    //滚动banner广告
    private var _scrollADImage:ScrollADImage?
    
    private var _nameLabel:UILabel = UILabel()
    private var _englishNameLabel:UILabel = UILabel()
    private var _cityLabel:UILabel = UILabel()
    private var _tableView:UITableView = UITableView()
    
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
        
        if countryID != "" && !_appearedFirstTime
        {
            _appearedFirstTime = true
            loadData()
        }
    }
    
    private func setup()
    {
        self.view.backgroundColor = VCBackgroundColor
        
        _scrollView.frame = self.view.frame
        _scrollView.bounces = true
        _scrollView.hidden = true
        self.view.addSubview(_scrollView)
        
        _scrollADImage = ScrollADImage(frame: CGRectMake(0, 0, self.view.width, 216))
        _scrollADImage!.backgroundColor = UIColor.whiteColor()
        _scrollView.addSubview(_scrollADImage!)
        
        _nameLabel.frame = CGRectMake(30, 30, self.view.width, 20)
        _nameLabel.userInteractionEnabled = false
        _nameLabel.font = UIFont.systemFontOfSize(16)
        _nameLabel.textColor = UIColor.whiteColor()
        _nameLabel.shadowColor = UIColor.blackColor()
        _nameLabel.shadowOffset = CGSizeMake(1, 1)
        _nameLabel.textAlignment = .Left
        _scrollView.addSubview(_nameLabel)
        
        _englishNameLabel.frame = CGRectMake(30, 58, _nameLabel.width, 20)
        _englishNameLabel.userInteractionEnabled = false
        _englishNameLabel.font = UIFont.systemFontOfSize(16)
        _englishNameLabel.textColor = UIColor.whiteColor()
        _englishNameLabel.shadowColor = UIColor.blackColor()
        _englishNameLabel.shadowOffset = CGSizeMake(1, 1)
        _englishNameLabel.textAlignment = .Left
        _scrollView.addSubview(_englishNameLabel)
        
        var buttonView:UIView = UIView()
        //穷游锦囊 使用贴士 微锦囊 推荐行程
        buttonView.frame = CGRectMake(0, _scrollADImage!.height, self.view.width, 90)
        buttonView.backgroundColor = UIColor.whiteColor()
        _scrollView.addSubview(buttonView)
        var bookBtn:UIButton = createButton("穷游锦囊", normalImage: UIImage(named: "detail_guide.png")!, hightlightedImage: UIImage(named: "detail_guide_hl.png")!, tag: 0, fontSize:14)
        bookBtn.y = 10
        buttonView.addSubview(bookBtn)
        
        var tipBtn:UIButton = createButton("使用贴士", normalImage: UIImage(named: "detail_tips.png")!, hightlightedImage: UIImage(named: "detail_tips_hl.png")!, tag: 1, fontSize:14)
        tipBtn.y = 10
        buttonView.addSubview(tipBtn)
        
        var tripBtn:UIButton = createButton("微锦囊", normalImage: UIImage(named: "detail_trip.png")!, hightlightedImage: UIImage(named: "detail_trip_hl.png")!, tag: 2, fontSize:14)
        tripBtn.y = 10
        buttonView.addSubview(tripBtn)
        
        var planBtn:UIButton = createButton("推荐行程", normalImage: UIImage(named: "detail_plan.png")!, hightlightedImage: UIImage(named: "detail_plan_hl.png")!, tag: 3, fontSize:14)
        planBtn.y = 10
        buttonView.addSubview(planBtn)
        
        //按钮间间隙宽度
        var gridWidth:CGFloat = (buttonView.width - bookBtn.width - tipBtn.width - tripBtn.width - planBtn.width) / 5
        bookBtn.x = gridWidth
        tipBtn.x = bookBtn.x + bookBtn.width + gridWidth
        tripBtn.x = tipBtn.x + tipBtn.width + gridWidth
        planBtn.x = tripBtn.x + tripBtn.width + gridWidth
        
        var hSeparatorLine1:UIView = UIView(frame: CGRectMake(0, buttonView.height - 0.5, buttonView.width, 0.5))
        hSeparatorLine1.backgroundColor = UIColor(white: 200 / 255, alpha: 1)
        buttonView.addSubview(hSeparatorLine1)
        
        //城市
        _cityLabel.textColor = UIColor.darkGrayColor()
        _cityLabel.sizeToFit()
        _cityLabel.frame = CGRectMake(10, buttonView.y + buttonView.height + 20, self.view.width * 0.5, 18)
        _scrollView.addSubview(_cityLabel)
        
        var moreCityBtn:UIButton = UIButton.buttonWithType(.System) as UIButton
        moreCityBtn.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
        moreCityBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
        moreCityBtn.setTitle("更多城市 >", forState: .Normal)
        moreCityBtn.sizeToFit()
        moreCityBtn.frame = CGRectMake(self.view.width - moreCityBtn.width - 10, _cityLabel.y - 8, moreCityBtn.width, moreCityBtn.height)
        moreCityBtn.addTarget(self, action: "showMoreCity", forControlEvents: .TouchUpInside)
        _scrollView.addSubview(moreCityBtn)
        
        var cityView:UIView = UIView()
        cityView.backgroundColor = UIColor.whiteColor()
        cityView.layer.borderColor = UIColor(white: 200 / 255, alpha: 1).CGColor
        cityView.layer.borderWidth = 0.5
        cityView.frame = CGRectMake(0, _cityLabel.bottom + 15, self.view.width, 140)
        _scrollView.addSubview(cityView)
        
        let numOfHorizontal:Int = 3
        let Grid:CGFloat = 10
        var cellWidth:CGFloat = (self.view.width - (CGFloat(numOfHorizontal + 1) * Grid)) / CGFloat(numOfHorizontal)
        var cellHeight:CGFloat = 55
        for i in 0..<6
        {
            var cellX:CGFloat = Grid + (CGFloat(i % numOfHorizontal) * (cellWidth + Grid))
            var cellY:CGFloat = Grid + (floor(CGFloat(i) / CGFloat(numOfHorizontal)) * (cellHeight + Grid))
            var tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "cityCellTapped:")
            var cell:SimpleCityCell = SimpleCityCell(frame: CGRectMake(cellX, cellY, cellWidth, cellHeight))
            cell.addGestureRecognizer(tapGesture)
            _cityCells.append(cell)
            cityView.addSubview(cell)
        }
        
        
        //新鲜好游记
        var journalLabel:UILabel = UILabel()
        journalLabel.font = UIFont.systemFontOfSize(14)
        journalLabel.text = "新鲜好游记"
        journalLabel.sizeToFit()
        journalLabel.frame = CGRectMake(10, cityView.bottom + 20, journalLabel.width, journalLabel.height)
        _scrollView.addSubview(journalLabel)
        
        var moreJournalBtn:UIButton = UIButton.buttonWithType(.System) as UIButton
        moreJournalBtn.titleLabel?.font = UIFont.systemFontOfSize(14)
        moreJournalBtn.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
        moreJournalBtn.setTitleColor(UIColor(white: 0.5, alpha: 1), forState: UIControlState.Highlighted)
        moreJournalBtn.setTitle("查看全部 >", forState: .Normal)
        moreJournalBtn.sizeToFit()
        moreJournalBtn.frame = CGRectMake(self.view.width - moreJournalBtn.width - 10, journalLabel.y - 8, moreJournalBtn.width, moreJournalBtn.height)
        moreJournalBtn.addTarget(self, action: "showMoreJournal", forControlEvents: .TouchUpInside)
        _scrollView.addSubview(moreJournalBtn)
        
        //游记列表
        let tableViewY:CGFloat = moreJournalBtn.bottom  + 10
        _tableView.rowHeight = TableViewCellHeight
        _tableView.scrollEnabled = false
        _tableView.frame = CGRectMake(0, tableViewY, self.view.width, 0)
        _tableView.dataSource = self
        _tableView.delegate = self
        _tableView.tableFooterView = UIView()
        _scrollView.addSubview(_tableView)
    }
    
    //创建按钮
    private func createButton(title:String, normalImage:UIImage, hightlightedImage:UIImage, tag:Int, fontSize:CGFloat)->UIButton
    {
        var button:UIButton = UIButton.buttonWithType(.Custom) as UIButton
        button.tag = tag
        button.setImage(normalImage, forState: .Normal)
        button.setImage(hightlightedImage, forState: .Highlighted)
        button.addTarget(self, action: "buttonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        button.sizeToFit()
        return button
    }
    
    //加载商品列表
    private func loadData()
    {
        incrementProgressView?.start()
        var url:String = "http://open.qyer.com/qyer/footprint/country_detail?client_id=qyer_ios&client_secret=cd254439208ab658ddf9&v=1&track_user_id=2061877&track_deviceid=14F93361-1204-496C-8444-78059A841B4F&track_app_version=5.4.4&track_app_channel=App%20Store&track_device_info=iPhone%205s&track_os=ios%207.1.2&lat=35.716210&lon=139.786830&oauth_token=4de3ee300e936008c61f6b9c0f175257&app_installtime=1419754055&country_id=\(countryID)"
        WebLoader.load(url, completionHandler: {(data:NSData!) in
            
            if(data != nil)
            {
                self.parseData(data!)
                self.incrementProgressView?.finish()
                //self.displayLoadingView(false)
            }
            
            }, errorHandler: {(error:NSError) in
                
                self.incrementProgressView?.finish()
                self.test()
                //self.displayLoadingView(false)
        })
    }
    
    private func test()
    {
        
    }
    
    //解析信息
    private func parseData(data:NSData)
    {
        let json = JSON(data: data)
        if let status = json["status"].integerValue
        {
            if status == 1
            {
                
                dispatch_async(dispatch_get_main_queue(),
                    {
                        self._scrollView.hidden = false
                        
                        let CountryName:String = json["data"]["chinesename"].stringValue ?? ""
                        self._nameLabel.text = CountryName
                        self._englishNameLabel.text = json["data"]["englishname"].stringValue ?? ""
                        self._cityLabel.text = CountryName + "城市"
                        //实用贴士
                        self._overviewURL = json["data"]["overview_url"].stringValue
                        if let photos = json["data"]["photos"].arrayValue
                        {
                            var ps:[String] = []
                            for i in 0..<photos.count
                            {
                                var photoURL:String = photos[i].stringValue ?? ""
                                if photoURL != ""
                                {
                                    ps.append(photoURL)
                                }
                            }
                            self._scrollADImage!.images = ps
                        }
                        
                        if let hotCities = json["data"]["hot_city"].arrayValue
                        {
                            for i in 0..<hotCities.count
                            {
                                if i < self._cityCells.count
                                {
                                    var cell:SimpleCityCell = self._cityCells[i]
                                    cell.id = hotCities[i]["id"].stringValue
                                    cell.update(hotCities[i]["photo"].stringValue, title: hotCities[i]["name"].stringValue)
                                }
                            }
                        }
                        
                        if let trips = json["data"]["new_trip"].arrayValue
                        {
                            var formatter:NSDateFormatter = NSDateFormatter()
                            formatter.dateFormat = "yyyy-MM-dd"
                            for i in 0..<trips.count
                            {
                                
                                var journal:Journal = Journal()
                                journal.name = trips[i]["username"].stringValue ?? ""
                                
                                journal.title = trips[i]["title"].stringValue ?? ""
                                journal.thumbURL = trips[i]["photo"].stringValue ?? ""
                                journal.viewURL = trips[i]["view_url"].stringValue ?? ""
                                var lastPost:NSString? = trips[i]["lastpost"].stringValue
                                if lastPost != nil
                                {
                                    var date:NSDate = NSDate(timeIntervalSince1970: lastPost!.doubleValue)
                                    journal.date = formatter.stringFromDate(date)
                                }
                                self._journals.append(journal)
                            }
                            self._tableView.height = CGFloat(self._journals.count) * self.TableViewCellHeight
                            self._tableView.reloadData()
                            
                            
                        }
                        
                        self._scrollView.contentSize = CGSizeMake(self.view.width, self._tableView.bottom)
                        
                })
            }
        }
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return _journals.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell:JournalCell? = tableView.dequeueReusableCellWithIdentifier("journalCell") as? JournalCell
        if cell == nil
        {
            cell = JournalCell(style: UITableViewCellStyle.Default, reuseIdentifier: "journalCell", cellWidth: self.view.width)
            println("create CommentCell")
        }
        var index:Int = indexPath.row
        var label:String = ""
        if index >= 0 && index < _journals.count
        {
            cell!.journal = _journals[index]
        }
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        var index:Int = indexPath.row
        if index >= 0 && index < _journals.count
        {
            var detailViewController:JournalDetailViewController = JournalDetailViewController()
            detailViewController.viewURL = _journals[index].viewURL
            self.navigationController!.pushViewController(detailViewController, animated: true)
        }
    }
    
    
    @objc private func buttonTapped(button:UIButton)
    {
        var index:Int = button.tag
        if index == 0
        {
            showMoreJournal()
        }
        else if index == 1
        {
            if _overviewURL != nil
            {
                var webViewController:WebViewController = WebViewController()
                webViewController.viewURL = _overviewURL!
                webViewController.autoTitleAfterLoadedFinish = false
                webViewController.title = "实用贴士"
                self.navigationController?.pushViewController(webViewController, animated: true)
            }
        }
        else if index == 2
        {
            showMicroBook()
        }
        else if index == 3
        {
            showRecommendScheduling()
        }
        
    }
    
    //打开城市列表
    @objc private func showMoreCity()
    {
        if countryID != ""
        {
            var cityTableViewController:CityTableViewController = CityTableViewController()
            cityTableViewController.countryID = countryID
            self.navigationController?.pushViewController(cityTableViewController, animated: true)
        }
    }
    
    //更多游记
    @objc private func showMoreJournal()
    {
        if countryID != ""
        {
            var essenceJournalViewController:EssenceJournalViewController = EssenceJournalViewController()
            essenceJournalViewController.id = countryID
            essenceJournalViewController.type = .Country
            self.navigationController?.pushViewController(essenceJournalViewController, animated: true)
        }
    }
    
    //微锦囊
    private func showMicroBook()
    {
        if countryID != ""
        {
            var microBookTableViewController:MicroBookTableViewController = MicroBookTableViewController()
            microBookTableViewController.id = countryID
            microBookTableViewController.type = .Country
            self.navigationController?.pushViewController(microBookTableViewController, animated: true)
        }
    }
    
    //推荐行程
    private func showRecommendScheduling()
    {
        if countryID != ""
        {
            var recommendSchedulingVC:RecommendSchedulingVC = RecommendSchedulingVC()
            recommendSchedulingVC.id = countryID
            recommendSchedulingVC.type = .Country
            self.navigationController?.pushViewController(recommendSchedulingVC, animated: true)
        }
    }
    
    @objc private func cityCellTapped(gesture:UITapGestureRecognizer)
    {
        var cell:SimpleCityCell = gesture.view as SimpleCityCell
        var cityDetailViewController:CityDetailViewController = CityDetailViewController()
        cityDetailViewController.cityID = cell.id ?? ""
        cityDetailViewController.title = cell.title
        self.navigationController!.pushViewController(cityDetailViewController, animated: true)
        
    }
    
}