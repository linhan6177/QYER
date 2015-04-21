//
//  FirstViewController.swift
//  QYer
//
//  Created by linhan on 15-4-6.
//  Copyright (c) 2015年 linhan. All rights reserved.
//

import UIKit
//游记
class Journal:NSObject
{
    var id:String?
    var name:String?
    var date:String?
    var title:String?
    var thumbURL:String?
    var viewURL:String?
    var avatarURL:String?
    var likeCount:Int?
    var commentCount:Int?
    var viewCount:Int?
    var caption:String?
    var placeCount:Int?
}
class RecommendationViewController: UIViewController,UITableViewDataSource,UITableViewDelegate
{

    
    private var _journals:[Journal] = []
    
    //已经加载的页数
    private var _loadedPage:Int = 2
    
    private var _headerRefreshing:Bool = false
    
    //滚动banner广告
    private var _scrollADImage:ScrollADImage?
    
    private var _tableHeaderView:UIView = UIView()
    
    private var _tableView:UITableView = UITableView()
    
    private var _books:[MainBookCover] = []
    
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    private func setup()
    {
        var testView:UIView = UIView()
        self.view.addSubview(testView)
        println("RecommendationViewController init")
        //self.title = "推荐"
        //self.navigationItem.title = "推荐"
        self.view.backgroundColor = UIColor.lightGrayColor()
        
        _tableHeaderView.frame = CGRectMake(0, 0, self.view.width, 700)
        _tableHeaderView.backgroundColor = UIColor(white: 220 / 255, alpha: 1)
        
        //滚动banner广告
        _scrollADImage = ScrollADImage(frame: CGRectMake(0, 0, self.view.width, 170))
        //_scrollADImage!.delegate = self
        self._scrollADImage!.images = [UIImage(named:"b1")!, UIImage(named:"b2")!, UIImage(named:"b3")!, UIImage(named:"b4")!]
        _tableHeaderView.addSubview(_scrollADImage!)
        
        //按钮
        var buttonView:UIView = UIView()
        buttonView.backgroundColor = UIColor.whiteColor()
        buttonView.frame = CGRectMake(0, _scrollADImage!.height, self.view.width, 90)
        _tableHeaderView.addSubview(buttonView)
        
        var bookBtn:UIButton = createButton("穷游锦囊", normalImage: UIImage(named: "book.png")!, hightlightedImage: UIImage(named: "press_book.png")!, tag: 0, fontSize:14)
        bookBtn.y = 10
        bookBtn.x = buttonView.width * 0.2 - (bookBtn.width * 0.5)
        buttonView.addSubview(bookBtn)
        
        var planBtn:UIButton = createButton("我的行程", normalImage: UIImage(named: "plan.png")!, hightlightedImage: UIImage(named: "press_plan.png")!, tag: 0, fontSize:14)
        planBtn.x = (buttonView.width - planBtn.width) * 0.5
        planBtn.y = 10
        buttonView.addSubview(planBtn)
        
        var featureBtn:UIButton = createButton("智能推荐", normalImage: UIImage(named: "feature.png")!, hightlightedImage: UIImage(named: "press_feature.png")!, tag: 0, fontSize:14)
        featureBtn.x = buttonView.width * 0.8 - (featureBtn.width * 0.5)
        featureBtn.y = 10
        buttonView.addSubview(featureBtn)
        
        var hSeparatorLine1:UIView = UIView(frame: CGRectMake(0, buttonView.height - 0.5, buttonView.width, 0.5))
        hSeparatorLine1.backgroundColor = UIColor(white: 200 / 255, alpha: 1)
        buttonView.addSubview(hSeparatorLine1)
        
        //微锦囊
        var bookLabel:UILabel = UILabel()
        bookLabel.textColor = UIColor.darkGrayColor()
        bookLabel.text = "微锦囊"
        bookLabel.sizeToFit()
        bookLabel.frame = CGRectMake(10, buttonView.y + buttonView.height + 20, bookLabel.width, bookLabel.height)
        _tableHeaderView.addSubview(bookLabel)
        
        let coverWidth:CGFloat = (self.view.width - 30) / 2
        
        var cover1:MainBookCover = MainBookCover(frame: CGRectMake(10, bookLabel.bottom + 15, coverWidth, 130), coverURL: "http://pic.qyer.com/album/user/575/1/RE5QQhsHZg/index/710x360", title: "食在博啦卡")
        _books.append(cover1)
        _tableHeaderView.addSubview(cover1)
        var cover2:MainBookCover = MainBookCover(frame: CGRectMake(coverWidth + 20, bookLabel.bottom + 15, coverWidth, 130), coverURL: "http://pic.qyer.com/album/user/671/52/R05URxgCYA/index/710x360", title: "东京平价美食餐厅推荐")
        _books.append(cover2)
        _tableHeaderView.addSubview(cover2)
        var cover3:MainBookCover = MainBookCover(frame: CGRectMake(10, cover1.bottom + 10, coverWidth, 130), coverURL: "http://pic.qyer.com/album/145/5e/2005030/index/710x360", title: "喷泉之旅逛罗马")
        _books.append(cover3)
        _tableHeaderView.addSubview(cover3)
        var cover4:MainBookCover = MainBookCover(frame: CGRectMake(coverWidth + 20, cover1.bottom + 10, coverWidth, 130), coverURL: "http://ad.qyer.com/www/images/d54288d746794ab5ba9e53111774095b.jpg", title: "纽约最棒的甜点/面包店")
        _books.append(cover4)
        _tableHeaderView.addSubview(cover4)
        
        //精华游记
        var journalLabel:UILabel = UILabel()
        journalLabel.textColor = UIColor.darkGrayColor()
        journalLabel.text = "精华游记"
        journalLabel.sizeToFit()
        journalLabel.frame = CGRectMake(10, cover4.bottom + 20, journalLabel.width, journalLabel.height)
        _tableHeaderView.addSubview(journalLabel)
        
        _tableHeaderView.height = journalLabel.bottom + 15
        
        
        var tableViewY:CGFloat = AppConfig.shared().statusBarHeight + AppConfig.shared().navigationBarHeight
        _tableView.frame = CGRectMake(0, tableViewY, self.view.width, self.view.height - tableViewY - AppConfig.shared().tabBarHeight)
        _tableView.rowHeight = 80
        _tableView.dataSource = self
        _tableView.delegate = self
        _tableView.tableFooterView = UIView()
        _tableView.tableHeaderView = _tableHeaderView
        self.view.addSubview(_tableView)
        
        setupRefresh()
        loadData()
    }
    
    //创建按钮
    private func createButton(title:String, normalImage:UIImage, hightlightedImage:UIImage, tag:Int, fontSize:CGFloat)->UIButton
    {
        var button:UIButton = UIButton.buttonWithType(.Custom) as UIButton
        button.tag = tag
        button.setImage(normalImage, forState: .Normal)
        button.setImage(hightlightedImage, forState: .Highlighted)
        button.sizeToFit()
        let font:UIFont = UIFont.systemFontOfSize(fontSize)
        let ButtonWidth:CGFloat = button.width
        let ButtonHeight:CGFloat = button.height
        let TextWidth:CGFloat = StringUtil.getStringWidth(title, font: font)
        
        button.titleEdgeInsets = UIEdgeInsets(top: ButtonHeight + 20, left: -(TextWidth + ButtonWidth) * 0.5, bottom: 0, right: 0)
        button.titleLabel?.font = font
        button.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        button.setTitle(title, forState: .Normal)
        button.addTarget(self, action: "buttonTapped:", forControlEvents: .TouchUpInside)
        button.sizeToFit()
        button.width = max(ButtonWidth, TextWidth)
        return button
    }
    
    func setupRefresh()
    {
        //上刷新取更多
        self._tableView.addFooterWithCallback({
            
            self._headerRefreshing = false
            self._loadedPage = self._loadedPage + 1
            self.loadJournals(page: self._loadedPage)
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
    
    //加载初始数据
    private func loadData()
    {
        var url:String = "http://open.qyer.com/qyer/recommands/index?client_id=qyer_ios&client_secret=cd254439208ab658ddf9&v=1&track_user_id=2061877&track_deviceid=14F93361-1204-496C-8444-78059A841B4F&track_app_version=5.4.4&track_app_channel=App%20Store&track_device_info=iPhone%205s&track_os=ios%207.1.2&lat=22.555020&lon=113.925114&oauth_token=4de3ee300e936008c61f6b9c0f175257&app_installtime=1419754055"
        WebLoader.load(url, completionHandler: {(data:NSData!) in
            
            if(data != nil)
            {
                self.parseData(data!)
                //self.displayLoadingView(false)
            }
            
            }, errorHandler: {(error:NSError) in
                
                //self.displayLoadingView(false)
        })
    }
    
    //加载游记
    private func loadJournals(page:Int = 1)
    {
        var url:String = "http://open.qyer.com/qyer/recommands/trip?client_id=qyer_ios&client_secret=cd254439208ab658ddf9&v=1&track_user_id=2061877&track_deviceid=14F93361-1204-496C-8444-78059A841B4F&track_app_version=5.4.4&track_app_channel=App%20Store&track_device_info=iPhone%205s&track_os=ios%207.1.2&lat=35.716210&lon=139.786830&oauth_token=4de3ee300e936008c61f6b9c0f175257&app_installtime=1419754055&type=index&count=10&page=\(page)&screensize=640"
        WebLoader.load(url, completionHandler: {(data:NSData!) in
            
            if(data != nil)
            {
                self.parseItemData(data!)
                //self.displayLoadingView(false)
                self.endFreshing()
            }
            
            }, errorHandler: {(error:NSError) in
                
                //self.displayLoadingView(false)
                self.endFreshing()
        })
    }
    
    private func parseData(data:NSData)
    {
        let json = JSON(data: data)
        if let status = json["status"].integerValue
        {
            if status == 1
            {
                var formatter:NSDateFormatter = NSDateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                
                //微锦囊
                if let books = json["data"]["mguide"].arrayValue
                {
                    for i in 0..<books.count
                    {
                        if i < _books.count
                        {
                            var tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "bookCoverTapped:")
                            var cover:MainBookCover = _books[i]
                            cover.id = books[i]["id"].stringValue
                            cover.update(books[i]["photo"].stringValue, title: books[i]["title"].stringValue)
                            cover.addGestureRecognizer(tapGesture)
                        }
                    }
                }
                
                //游记
                if let items = json["data"]["trip"].arrayValue
                {
                    for i in 0..<items.count
                    {
                        var journal:Journal = Journal()
                        journal.name = items[i]["username"].stringValue ?? ""
                        journal.title = items[i]["title"].stringValue ?? ""
                        journal.thumbURL = items[i]["photo"].stringValue ?? ""
                        journal.viewURL = items[i]["view_url"].stringValue ?? ""
                        var lastPost:NSString? = items[i]["lastpost"].stringValue
                        if lastPost != nil
                        {
                            var date:NSDate = NSDate(timeIntervalSince1970: lastPost!.doubleValue)
                            journal.date = formatter.stringFromDate(date)
                        }
                        _journals.append(journal)
                    }
                }
                
                
                dispatch_async(dispatch_get_main_queue(),
                    {
                        self._tableView.reloadData()
                })
            }
            
        }
    }
    
    //解析商品信息
    private func parseItemData(data:NSData)
    {
        let json = JSON(data: data)
        if let status = json["status"].integerValue
        {
            if status == 1
            {
                var formatter:NSDateFormatter = NSDateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                if let items = json["data"].arrayValue
                {
                    for i in 0..<items.count
                    {
                        var journal:Journal = Journal()
                        journal.name = items[i]["username"].stringValue ?? ""
                        journal.title = items[i]["title"].stringValue ?? ""
                        journal.thumbURL = items[i]["photo"].stringValue ?? ""
                        journal.viewURL = items[i]["view_url"].stringValue ?? ""
                        var lastPost:NSString? = items[i]["lastpost"].stringValue
                        if lastPost != nil
                        {
                            var date:NSDate = NSDate(timeIntervalSince1970: lastPost!.doubleValue)
                            journal.date = formatter.stringFromDate(date)
                        }
                        _journals.append(journal)
                    }
                    
                    dispatch_async(dispatch_get_main_queue(),
                        {
                            self._tableView.reloadData()
                    })
                    
                }
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
        
    }
    
    @objc private func bookCoverTapped(gesture:UITapGestureRecognizer)
    {
        var cover:MainBookCover = gesture.view as MainBookCover
        if cover.id != nil && cover.id! != ""
        {
            var detailViewController:MicroBookDetailViewController = MicroBookDetailViewController()
            detailViewController.id = cover.id!
            //detailViewController.title = _journals[index].title
            self.navigationController!.pushViewController(detailViewController, animated: true)
        }
        
    }
    
    
    
    
    
}

