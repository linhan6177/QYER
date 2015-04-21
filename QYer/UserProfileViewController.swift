//
//  UserProfileViewController.swift
//  QYer
//
//  Created by linhan on 15-4-6.
//  Copyright (c) 2015年 linhan. All rights reserved.
//

import UIKit
class UserProfileViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate
{
    
    private enum SettingAction:Int
    {
        case ClearCache
        case ChooseQuality
        case SubMenu
    }
    private struct SettingItem
    {
        var icon:UIImage
        var title:String
        var sub:Bool
        var action:SettingAction
    }
    private var _settings:[SettingItem] = []
    
    private var _imageWidth:CGFloat = 0
    
    private var _imageHeight:CGFloat = 0
    
    private var _scrollView:UIScrollView = UIScrollView()
    
    private var _navigationBarBgView:UIView = UIView()
    
    private var _headerView:UIView = UIView()
    
    private var _profileImageView:UIImageView = UIImageView(image:UIImage(named:"Bg_user.png")!)
    
    private var _buttonsView:UIView = UIView()
    
    private var _tableView:UITableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setup()
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        if self.navigationController != nil && !self.navigationController!.navigationBarHidden
        {
            self.navigationController!.navigationBarHidden = true
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setup()
    {
        println("UserProfileViewController init")
        _imageWidth = _profileImageView.frame.width
        _imageHeight = _profileImageView.frame.height
        
        //推送设置 图片质量 清除缓存 app推荐 更多
        _settings.append(SettingItem(icon: UIImage(named: "ic_user_set.png")!, title: "我的锦囊", sub: true, action:.SubMenu))
        _settings.append(SettingItem(icon: UIImage(named: "ic_user_img.png")!, title: "我的折扣", sub: true, action:.ChooseQuality))
        _settings.append(SettingItem(icon: UIImage(named: "ic_user_delete.png")!, title: "我的行程", sub: true, action:.ClearCache))
        _settings.append(SettingItem(icon: UIImage(named: "ic_user_apptuijian.png")!, title: "我的帖子", sub: true, action:.SubMenu))
        
        self.view.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(_profileImageView)
        
        _scrollView.frame = CGRectMake(0, 0, self.view.width, self.view.height - AppConfig.shared().tabBarHeight)
        _scrollView.bounces = true
        _scrollView.delegate = self
        self.view.addSubview(_scrollView)
        
        //320 * 240
        _headerView.frame = _profileImageView.frame
        _scrollView.addSubview(_headerView)
        //阴影
        var shadowImageView:UIImageView = UIImageView(image:UIImage(named:"Bg_mengceng.png")!)
        shadowImageView.frame = CGRectMake(0, _headerView.height - shadowImageView.height, _profileImageView.width, shadowImageView.height)
        _headerView.addSubview(shadowImageView)
        
        //头像
        var avatar:UIImageView = UIImageView(image:UIImage(named:"avatar.png"))
        avatar.frame = CGRectMake((_headerView.width - avatar.width) * 0.5, _headerView.height * 0.5 - avatar.height, avatar.width, avatar.height)
        _headerView.addSubview(avatar)
        
        var userNameLabel:UILabel = UILabel()
        userNameLabel.font = UIFont.systemFontOfSize(18)
        userNameLabel.textAlignment = .Center
        userNameLabel.textColor = UIColor.whiteColor()
        userNameLabel.text = "穷游用户"
        userNameLabel.frame = CGRectMake(0, _headerView.height * 0.5, _headerView.width, 20)
        _headerView.addSubview(userNameLabel)
        
        //分割线
        var hSeparatorLine1:UIView = UIView(frame: CGRectMake(0, _headerView.height - 40, _headerView.width, 0.5))
        hSeparatorLine1.backgroundColor = UIColor(white: 150 / 255, alpha: 0.5)
        _headerView.addSubview(hSeparatorLine1)
        
        var VSeparatorLine1:UIView = UIView(frame: CGRectMake(_headerView.width * 0.5, _headerView.height - 40, 0.5, 40))
        VSeparatorLine1.backgroundColor = UIColor(white: 150 / 255, alpha: 0.5)
        _headerView.addSubview(VSeparatorLine1)
        
        var followLabel:UILabel = UILabel()
        followLabel.textAlignment = .Center
        followLabel.textColor = UIColor.whiteColor()
        followLabel.text = "100关注"
        followLabel.frame = CGRectMake(0, _headerView.height - 30, _headerView.width * 0.5, 20)
        _headerView.addSubview(followLabel)
        
        var fansLabel:UILabel = UILabel()
        fansLabel.textAlignment = .Center
        fansLabel.textColor = UIColor.whiteColor()
        fansLabel.text = "59粉丝"
        fansLabel.frame = CGRectMake(_headerView.width * 0.5, _headerView.height - 30, _headerView.width * 0.5, 20)
        _headerView.addSubview(fansLabel)
        
        //106 110
        _buttonsView.frame = CGRectMake(0, _headerView.height, self.view.width, 220)
        var mapView:UIImageView = UIImageView(image:UIImage(named:"map.png"))
        mapView.frame = CGRectMake((_buttonsView.width - mapView.width) * 0.5, 15, mapView.width, mapView.height)
        _buttonsView.addSubview(mapView)
        
        
        _scrollView.addSubview(_buttonsView)
        
        _tableView.rowHeight = 44
        _tableView.frame = CGRectMake(0, _buttonsView.y + _buttonsView.height + 10, self.view.width, _tableView.rowHeight * CGFloat(_settings.count))
        _tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "settingCell")
        _tableView.dataSource = self
        _tableView.delegate = self
        _scrollView.addSubview(_tableView)
        _scrollView.contentSize = CGSizeMake(_scrollView.width, _tableView.y + _tableView.height + 40)
        
        _navigationBarBgView.alpha = 0
        _navigationBarBgView.backgroundColor = UIColor(red: 0, green: 0.8, blue: 0, alpha: 1)
        _navigationBarBgView.frame = CGRectMake(0, 0, self.view.width, AppConfig.shared().navigationBarHeight + AppConfig.shared().statusBarHeight)
        self.view.addSubview(_navigationBarBgView)
        
        var settingBtn:UIButton = UIButton.buttonWithType(.Custom) as UIButton
        settingBtn.setBackgroundImage(UIImage(named: "ic_user_set.png"), forState: UIControlState.Normal)
        settingBtn.sizeToFit()
        settingBtn.frame = CGRectMake(self.view.width - settingBtn.width - 20, 30, settingBtn.width, settingBtn.height)
        self.view.addSubview(settingBtn)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView)
    {
        if scrollView == _scrollView
        {
            var yOffset:CGFloat = scrollView.contentOffset.y
            var rect:CGRect
            if yOffset < 0
            {
                var newHeight:CGFloat = abs(yOffset) + _imageHeight
                var newWidth:CGFloat = (newHeight / _imageHeight) * _imageWidth
                rect = CGRectMake((self.view.width - newWidth) / 2, 0, newWidth, newHeight)
                _profileImageView.frame = rect
            }
            else
            {
                var navigationBarBgViewAlpha:CGFloat = 0
                if yOffset > 100
                {
                    navigationBarBgViewAlpha = yOffset > 150 ? 1 : ((yOffset - 100) / 50)
                }
                else
                {
                    navigationBarBgViewAlpha = 0
                }
                rect = _profileImageView.frame
                rect.origin.y = -yOffset
                _profileImageView.frame = rect
                
                if navigationBarBgViewAlpha != _navigationBarBgView.alpha
                {
                    _navigationBarBgView.alpha = navigationBarBgViewAlpha
                }
            }
        }
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return _settings.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("settingCell") as UITableViewCell
        var index:Int = indexPath.row
        if index >= 0 && index < _settings.count
        {
            var item:SettingItem = _settings[index]
            cell.imageView?.image = item.icon
            cell.textLabel?.text = item.title
            cell.textLabel?.textColor = UIColor.darkGrayColor()
            cell.accessoryType = item.sub ? UITableViewCellAccessoryType.DisclosureIndicator : UITableViewCellAccessoryType.None
            if item.action == .ClearCache
            {
                //updateCacheCapacity()
                //cell.accessoryView = _capacityLabel
            }
        }
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        var index:Int = indexPath.row
        if index >= 0 && index < _settings.count
        {
            var item:SettingItem = _settings[index]
            if item.action == .ClearCache
            {
                //clearCache()
            }
        }
    }
    
    
}