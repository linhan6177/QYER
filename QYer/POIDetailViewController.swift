//
//  POIDetailViewController.swift
//  QYer
//
//  Created by linhan on 15-4-18.
//  Copyright (c) 2015年 linhan. All rights reserved.
//

import Foundation
import UIKit



class POIDetailViewController: UIViewController {
    
    var id:String = ""
    
    private var _appearedFirstTime:Bool = false
    private var _totalPhotos:Int = 0
    //描述在折叠与未折叠下的高度
    private var _folded:Bool = false
    private var _introductionFoldedHeight:CGFloat = 70
    private var _introductionUnfoldedHeight:CGFloat = 70
    private var _introductionLabelY:CGFloat = 0
    
    class BasicInfo:NSObject
    {
        var icon:UIImage?
        var title:String?
        var content:String?
        var sub:Bool = false
        
        init(icon:UIImage, title:String?, content:String?, sub:Bool = false)
        {
            self.icon = icon
            self.title = title
            self.content = content
            self.sub = sub
        }
    }
    private var _basicInfos:[BasicInfo] = []
    
    private var _scrollView:UIScrollView = UIScrollView()
    private var _titleView:POITitleView = POITitleView(frame: CGRectMake(0, 0, 200, 40))
    private var _coverImageView:ImageLoader?
    lazy private var _photoCountLabel:UILabel = UILabel()
    lazy private var _commentCountLabel:UILabel = UILabel()
    lazy private var _beenCountLabel:UILabel = UILabel()
    private var _introductionView:UIView = UIView()
    private var _introductionLabel:UILabel = UILabel()
    private var _foldBtn:UIButton = UIButton.buttonWithType(.System) as UIButton
    private var _bottomView:UIView = UIView()
    private var _basicInfoView:UIView = UIView()
    
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
        self.view.backgroundColor = VCBackgroundColor
        
        self.navigationItem.titleView = _titleView
        
        _scrollView.frame = self.view.frame
        _scrollView.bounces = true
        _scrollView.hidden = true
        self.view.addSubview(_scrollView)
        
        //封面
        var coverGesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "coverTapped:")
        _coverImageView = ImageLoader(frame: CGRectMake(0, 0, self.view.width, 220))
        _coverImageView!.userInteractionEnabled = true
        _coverImageView!.completeCallback = imageLoadedCompleteCallback
        _coverImageView!.addGestureRecognizer(coverGesture)
        _scrollView.addSubview(_coverImageView!)
        
        _photoCountLabel.frame = CGRectMake(self.view.width - 70, 10, 60, 17)
        _photoCountLabel.textColor = UIColor.whiteColor()
        _photoCountLabel.font = UIFont.systemFontOfSize(13)
        _photoCountLabel.backgroundColor = UIColor(white: 0, alpha: 0.5)
        _photoCountLabel.textAlignment = .Center
        _scrollView.addSubview(_photoCountLabel)
        
        
        var bolderColor:UIColor = UIColor(white: 200 / 255, alpha: 1)
        
        var darkView:UIView = UIView()
        darkView.backgroundColor = UIColor.darkGrayColor()
        darkView.frame = CGRectMake(0, _coverImageView!.bottom, self.view.width, 50)
        _scrollView.addSubview(darkView)
        
        _beenCountLabel.frame = CGRectMake(10, 5, self.view.width * 0.5 - 20, 18)
        _beenCountLabel.textColor = UIColor.whiteColor()
        _beenCountLabel.font = UIFont.systemFontOfSize(13)
        darkView.addSubview(_beenCountLabel)
        
        _commentCountLabel.frame = CGRectMake(self.view.width * 0.5 + 10, 5, self.view.width * 0.5 - 20, 18)
        _commentCountLabel.textColor = UIColor.whiteColor()
        _commentCountLabel.font = UIFont.systemFontOfSize(13)
        darkView.addSubview(_commentCountLabel)
        
        var hotImageView:UIImageView = UIImageView(image:UIImage(named:"poi_hot_1"))
        hotImageView.frame = CGRectMake(_beenCountLabel.x, _beenCountLabel.bottom + 5, hotImageView.width, hotImageView.height)
        darkView.addSubview(hotImageView)
        
        var starImageView:UIImageView = UIImageView(image:UIImage(named:"poi_detail_star_full"))
        starImageView.frame = CGRectMake(_commentCountLabel.x, _commentCountLabel.bottom + 5, starImageView.width, starImageView.height)
        darkView.addSubview(starImageView)

        var vSeparatorLine1:UIView = UIView(frame: CGRectMake(darkView.width * 0.5, 5, 0.5, darkView.height - 10))
        vSeparatorLine1.backgroundColor = UIColor(white: 200 / 255, alpha: 1)
        darkView.addSubview(vSeparatorLine1)
        
        //简介
        _introductionView.frame = CGRectMake(0, darkView.bottom + 10, self.view.width, 130)
        _introductionView.clipsToBounds = true
        _introductionView.layer.borderColor = bolderColor.CGColor
        _introductionView.layer.borderWidth = 0.5
        _introductionView.backgroundColor = UIColor.whiteColor()
        _scrollView.addSubview(_introductionView)
        
        var introductionTitleLabel:UILabel = UILabel()
        introductionTitleLabel.font = UIFont.systemFontOfSize(15)
        introductionTitleLabel.text = "简介"
        introductionTitleLabel.sizeToFit()
        introductionTitleLabel.frame = CGRectMake(10, 10, introductionTitleLabel.width, introductionTitleLabel.height)
        _introductionView.addSubview(introductionTitleLabel)
        
        var hSeparatorLine1:UIView = UIView(frame: CGRectMake(10, introductionTitleLabel.bottom + 10, _introductionView.width - 10, 0.5))
        hSeparatorLine1.backgroundColor = bolderColor
        _introductionView.addSubview(hSeparatorLine1)
        
        _introductionLabelY = hSeparatorLine1.bottom + 5
        _introductionLabel.frame = CGRectMake(10, _introductionLabelY, _introductionView.width - 20, 20)
        _introductionLabel.font = UIFont.systemFontOfSize(14)
        _introductionLabel.textColor = UIColor.darkGrayColor()
        _introductionLabel.numberOfLines = 0
        _introductionView.addSubview(_introductionLabel)
        
        _foldBtn.setImage(UIImage(named:"poidetail_arrow_down"), forState: .Normal)
        _foldBtn.hidden = true
        _foldBtn.sizeToFit()
        _foldBtn.frame = CGRectMake((_introductionView.width - _foldBtn.width) * 0.5, 0, min(_foldBtn.width, 44), min(_foldBtn.height, 44))
        _foldBtn.addTarget(self, action: "fold", forControlEvents: .TouchUpInside)
        _introductionView.addSubview(_foldBtn)
        
        //简介一下的视图
        _bottomView.frame = CGRectMake(0, _introductionView.bottom + 10, self.view.width, 100)
        _scrollView.addSubview(_bottomView)
        
        //基本信息
        _basicInfoView.frame = CGRectMake(0, 0, _bottomView.width, 0)
        _basicInfoView.backgroundColor = UIColor.whiteColor()
        _basicInfoView.layer.borderColor = bolderColor.CGColor
        _basicInfoView.layer.borderWidth = 0.5
        _bottomView.addSubview(_basicInfoView)
        
        var basicTitleLabel:UILabel = UILabel()
        basicTitleLabel.font = UIFont.systemFontOfSize(15)
        basicTitleLabel.text = "基本信息"
        basicTitleLabel.sizeToFit()
        basicTitleLabel.frame = CGRectMake(10, 10, basicTitleLabel.width, basicTitleLabel.height)
        _basicInfoView.addSubview(basicTitleLabel)
        
        var hSeparatorLine2:UIView = UIView(frame: CGRectMake(10, basicTitleLabel.bottom + 10, _basicInfoView.width - 10, 0.5))
        hSeparatorLine2.backgroundColor = bolderColor
        _basicInfoView.addSubview(hSeparatorLine2)
        
        _basicInfoView.height = hSeparatorLine2.bottom
        
        
        
    }
    
    //加载商品列表
    private func loadData()
    {
        incrementProgressView?.start()
        var url:String = "http://open.qyer.com/qyer/footprint/poi_detail?client_id=qyer_ios&client_secret=cd254439208ab658ddf9&v=1&track_user_id=2061877&track_deviceid=14F93361-1204-496C-8444-78059A841B4F&track_app_version=5.4.4&track_app_channel=App%20Store&track_device_info=iPhone%205s&track_os=ios%207.1.2&lat=22.555020&lon=113.925114&oauth_token=4de3ee300e936008c61f6b9c0f175257&app_installtime=1419754055&screensize=640&poi_id=\(id)"
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
                var chineseName:String? = json["data"]["chinesename"].stringValue
                var otherName:String? = json["data"]["englishname"].stringValue ?? json["data"]["localname"].stringValue
                _totalPhotos = json["data"]["img_count"].stringValue != nil ? (json["data"]["img_count"].stringValue! as NSString).integerValue : 0
                var numComments:String = json["data"]["commentcounts"].stringValue ?? "0"
                var numBeenTo:String = json["data"]["beentocounts"].stringValue ?? "0"
                var introduction:String = json["data"]["introduction"].stringValue ?? ""
                let IntroductionTextHeight:CGFloat = StringUtil.getStringHeight(introduction, font: _introductionLabel.font, width: _introductionLabel.width)
                var address:String? = json["data"]["address"].stringValue
                if address != nil && address! != ""
                {
                    _basicInfos.append(BasicInfo(icon: UIImage(named:"poi_detail_address_icon")!, title: "地址", content: address!, sub: true))
                }
                var wayTo:String? = json["data"]["wayto"].stringValue
                if wayTo != nil && wayTo! != ""
                {
                    _basicInfos.append(BasicInfo(icon: UIImage(named:"poi_detail_way_icon")!, title: "路线", content: wayTo!, sub: false))
                }
                var openTime:String? = json["data"]["opentime"].stringValue
                if openTime != nil && openTime! != ""
                {
                    _basicInfos.append(BasicInfo(icon: UIImage(named:"poi_detail_time_icon")!, title: "时间", content: openTime!, sub: false))
                }
                var price:String? = json["data"]["price"].stringValue
                if price != nil && price! != ""
                {
                    _basicInfos.append(BasicInfo(icon: UIImage(named:"poi_detail_ticket_icon")!, title: "门票", content: price!, sub: false))
                }
                var phone:String? = json["data"]["phone"].stringValue
                if phone != nil && phone! != ""
                {
                    _basicInfos.append(BasicInfo(icon: UIImage(named:"poi_detail_tel_icon")!, title: "电话", content: phone!, sub: true))
                }
                var site:String? = json["data"]["site"].stringValue
                if site != nil && site! != ""
                {
                    _basicInfos.append(BasicInfo(icon: UIImage(named:"poi_detail_link_icon")!, title: "网址", content: site!, sub: true))
                }
                
                
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    self._titleView.update(chineseName, englishName: otherName)
                    if coverURL != nil
                    {
                        self._coverImageView?.load(coverURL!)
                    }
                    self._photoCountLabel.text = "\(self._totalPhotos)张 >"
                    self._beenCountLabel.text = "\(numBeenTo)个穷游er去过"
                    self._commentCountLabel.text = "\(numComments)条点评"
                    self._introductionLabel.text = introduction
                    let IntroductionOverflow:Bool = IntroductionTextHeight > 52
                    if IntroductionOverflow
                    {
                        self._introductionLabel.height = 52
                        self._folded = true
                    }
                    else
                    {
                        self._introductionLabel.height = IntroductionTextHeight
                    }
                    self._foldBtn.hidden = !IntroductionOverflow
                    self._foldBtn.y = self._introductionLabel.bottom + 8
                    self._introductionView.height = IntroductionOverflow ? self._foldBtn.bottom + 5 : self._foldBtn.y
                    self._introductionFoldedHeight = self._introductionView.height
                    self._introductionUnfoldedHeight = self._introductionLabel.y + IntroductionTextHeight + 8 + self._foldBtn.height + 5
                    
                    //
                    self._bottomView.y = self._introductionView.bottom + 10
                    
                    //基本信息
                    var infoCount:Int = self._basicInfos.count
                    var basicInfoViewHeight:CGFloat = self._basicInfoView.height
                    for i in 0..<infoCount
                    {
                        var info:BasicInfo = self._basicInfos[i]
                        var cell:POIBasicInfoCell = POIBasicInfoCell(width: self.view.width, image: info.icon, title: info.title, content: info.content)
                        cell.y = basicInfoViewHeight
                        basicInfoViewHeight = cell.y + cell.height + 0.5
                        self._basicInfoView.addSubview(cell)
                        
                        if i < (infoCount - 1)
                        {
                            var hSeparatorLine1:UIView = UIView(frame: CGRectMake(10, cell.bottom, cell.width - 10, 0.5))
                            hSeparatorLine1.backgroundColor = UIColor(white: 0.85, alpha: 1)
                            self._basicInfoView.addSubview(hSeparatorLine1)
                        }
                    }
                    self._basicInfoView.height = basicInfoViewHeight
                    self._bottomView.height = self._basicInfoView.bottom
                    
                    self._scrollView.contentSize = CGSizeMake(self.view.width, self._bottomView.bottom + 20)
                    self._scrollView.hidden = false
                    
                    
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
    
    
    //封面点击
    @objc private func coverTapped(gesture:UITapGestureRecognizer)
    {
        if id != ""
        {
            var photoListViewController:PhotoListViewController = PhotoListViewController()
            photoListViewController.id = id
            photoListViewController.totalPhotos = _totalPhotos
            self.navigationController?.pushViewController(photoListViewController, animated: true)
        }
    }
    
    //折叠文字
    @objc private func fold()
    {
        var introductionViewHeight:CGFloat = 0
        if _folded
        {
            _folded = false
            introductionViewHeight = _introductionUnfoldedHeight
        }
        else
        {
            _folded = true
            introductionViewHeight = _introductionFoldedHeight
        }
        let foldBtnY:CGFloat = introductionViewHeight - 5 - self._foldBtn.height
        let introductionLabelFrame:CGRect = CGRectMake(10, self._introductionLabelY, self._introductionLabel.width, foldBtnY - 8 - self._introductionLabelY)
        
        if self._folded
        {
            self._introductionLabel.frame = introductionLabelFrame
        }
        
        UIView.animateWithDuration(0.3, animations: {
            
            self._introductionView.height = introductionViewHeight
            self._foldBtn.y = foldBtnY
            self._bottomView.y = self._introductionView.bottom + 10
            
            }, completion: {(finish:Bool) in
        
            if !self._folded
            {
                self._introductionLabel.frame = introductionLabelFrame
            }
            
        })
        
        self._scrollView.contentSize = CGSizeMake(self.view.width, self._bottomView.bottom + 20)
    }
    
    
}