//
//  MicroBookDetailViewController.swift
//  QYer
//
//  Created by linhan on 15-4-16.
//  Copyright (c) 2015年 linhan. All rights reserved.
//

import Foundation
import UIKit


class POI:NSObject
{
    var id:String?
    var firstName:String?
    var secondName:String?
    var localName:String?
    var chineseName:String?
    var englishName:String?
    var countryName:String?
    var cityName:String?
    var lat:Double?
    var lng:Double?
    var recommandStar:Int?
    var coverURL:String?
    var POIDescription:String?
    var cellHeight:CGFloat = 0
}

class MicroBookDetailViewController: UITableViewController
{
    var id:String = ""
    private var _appearedFirstTime:Bool = false
    
    private var _pois:[POI] = []
    private var _totalPOIs:Int = 0
    
    private var _headerView:UIView = UIView()
    private var _coverImageView:ImageLoader?
    private var _avatarImageView:ImageLoader?
    lazy private var _countLabel:UILabel = UILabel()
    private var _nameLabel:UILabel = UILabel()
    private var _titleLabel:UILabel = UILabel()
    private var _descriptionLabel:UILabel = UILabel()
    
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
            if id != ""
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
        self.title = "微锦囊详情"
        self.view.backgroundColor = UIColor(white: 230 / 250, alpha: 1)
        
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = .None
        
        //封面
        _coverImageView = ImageLoader(frame: CGRectMake(0, 0, self.view.width, 220))
        _coverImageView!.completeCallback = imageLoadedCompleteCallback
        _headerView.addSubview(_coverImageView!)
        
        //头像
        let avatarDiameter:CGFloat = 40
        _avatarImageView = ImageLoader(frame: CGRectMake((self.view.width - avatarDiameter) * 0.5, _coverImageView!.height - (avatarDiameter * 0.5), avatarDiameter, avatarDiameter))
        _avatarImageView!.layer.cornerRadius = _avatarImageView!.width * 0.5
        _avatarImageView!.layer.masksToBounds = true
        _headerView.addSubview(_avatarImageView!)
        
        _countLabel.backgroundColor = UIColor(white: 0, alpha: 0.5)
        _countLabel.textColor = UIColor.whiteColor()
        _countLabel.textAlignment = .Center
        _countLabel.font = UIFont.systemFontOfSize(13)
        _countLabel.text = " 10个旅行地 "
        _countLabel.sizeToFit()
        _countLabel.frame = CGRectMake(self.view.width - _countLabel.width - 20, 10, _countLabel.width, _countLabel.height)
        _headerView.addSubview(_countLabel)
        
        //昵称
        _nameLabel.frame = CGRectMake(0, _avatarImageView!.bottom + 5, self.view.width, 16)
        _nameLabel.font = UIFont.systemFontOfSize(12)
        _nameLabel.textColor = UIColor(white: 0.3, alpha: 1)
        _nameLabel.textAlignment = .Center
        _headerView.addSubview(_nameLabel)
        
        //标题
        let titleLeftMargin:CGFloat = 40
        _titleLabel.frame = CGRectMake(titleLeftMargin, _nameLabel.bottom + 15, self.view.width - (titleLeftMargin * 2), 22)
        _titleLabel.font = UIFont.systemFontOfSize(18)
        _titleLabel.textColor = UIColor.blackColor()
        _titleLabel.textAlignment = .Center
        _headerView.addSubview(_titleLabel)

        
        //描述
        _descriptionLabel.frame = CGRectMake(titleLeftMargin, _titleLabel.bottom + 15, self.view.width - (titleLeftMargin * 2), 22)
        _descriptionLabel.numberOfLines = 0
        _descriptionLabel.font = UIFont.systemFontOfSize(14)
        _descriptionLabel.textColor = UIColor.darkGrayColor()
        _headerView.addSubview(_descriptionLabel)
    }
    
    //加载商品列表
    private func loadData(page:Int = 1)
    {
        incrementProgressView?.start()
        var url:String = "http://open.qyer.com/qyer/footprint/mguide_detail?client_id=qyer_ios&client_secret=cd254439208ab658ddf9&v=1&track_user_id=2061877&track_deviceid=14F93361-1204-496C-8444-78059A841B4F&track_app_version=5.4.4&track_app_channel=App%20Store&track_device_info=iPhone%205s&track_os=ios%207.1.2&lat=22.555020&lon=113.925114&oauth_token=4de3ee300e936008c61f6b9c0f175257&app_installtime=1419754055&id=\(id)&source=&page=\(page)&oauth_token=4de3ee300e936008c61f6b9c0f175257"
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
                var coverURL:String? = json["data"]["photo"].stringValue
                var title:String? = json["data"]["title"].stringValue
                var author:String? = json["data"]["username"].stringValue
                var avatarURL:String? = json["data"]["avatar"].stringValue
                var description:String? = json["data"]["description"].stringValue
                _totalPOIs = json["data"]["count"].integerValue ?? 0
                if let pois = json["data"]["pois"].arrayValue
                {
                    for i in 0..<pois.count
                    {
                        var poi:POI = POI()
                        poi.id = pois[i]["id"].stringValue
                        poi.chineseName = pois[i]["chinesename"].stringValue
                        poi.countryName = pois[i]["countryname"].stringValue
                        poi.cityName = pois[i]["cityname"].stringValue
                        poi.recommandStar = pois[i]["recommandstar"].integerValue
                        poi.coverURL = pois[i]["photo"].stringValue
                        poi.POIDescription = pois[i]["description"].stringValue
                        poi.lat = pois[i]["lat"].stringValue == nil ? nil : (pois[i]["lat"].stringValue! as NSString).doubleValue
                        poi.lng = pois[i]["lng"].stringValue == nil ? nil : (pois[i]["lng"].stringValue! as NSString).doubleValue
                        
                        self._pois.append(poi)
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    
                    if coverURL != nil
                    {
                        self._coverImageView?.load(coverURL!)
                    }
                    if avatarURL != nil
                    {
                        self._avatarImageView?.load(avatarURL!)
                    }
                    self._countLabel.text = " \(self._totalPOIs ?? 0)个旅行地 "
                    self._nameLabel.text = author ?? ""
                    self._titleLabel.text = title ?? ""
                    var descriptionHeight:CGFloat = StringUtil.getStringHeight(description ?? "", font: self._descriptionLabel.font, width: self._descriptionLabel.width)
                    self._descriptionLabel.height = descriptionHeight
                    self._descriptionLabel.text = description ?? ""
                    self._headerView.height = self._descriptionLabel.bottom + 10
                    self.tableView.tableHeaderView = self._headerView
                    self.tableView.reloadData()
                })
                
                
            }
            
        }
        
    }
    
    private func imageLoadedCompleteCallback(imageView:UIImageView, readFromCache:Bool)
    {
        //第一次从网络加载时进行缓存
        if  !readFromCache
        {
            imageView.alpha = 0
            UIView.animateWithDuration(0.3, animations: {
                imageView.alpha = 1
            })
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        var height:CGFloat = 0
        var index:Int = indexPath.row
        if index >= 0 && index < _pois.count
        {
            height = _pois[index].cellHeight
            if height == 0
            {
                height = POICell.getCellHeight(self.view.width, text: _pois[index].POIDescription ?? "")
                _pois[index].cellHeight = height
                if height == 0
                {
                    height = 150
                }
            }
        }
        
        return height
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return _pois.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell:POICell? = tableView.dequeueReusableCellWithIdentifier("POICell") as? POICell
        if cell == nil
        {
            cell = POICell(style: UITableViewCellStyle.Default, reuseIdentifier: "POICell", cellWidth: self.view.width)
            println("create POICell")
        }
        var index:Int = indexPath.row
        if index >= 0 && index < _pois.count
        {
            cell!.data = _pois[index]
        }
        return cell!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        var index:Int = indexPath.row
        if index >= 0 && index < _pois.count
        {
            var poi:POI = _pois[index]
            if poi.id != nil &&  poi.id! != ""
            {
                var detailViewController:POIDetailViewController = POIDetailViewController()
                detailViewController.id = poi.id!
                self.navigationController!.pushViewController(detailViewController, animated: true)
            }
        }
    }
    
    
}