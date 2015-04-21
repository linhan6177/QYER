//
//  SecondViewController.swift
//  QYer
//
//  Created by linhan on 15-4-6.
//  Copyright (c) 2015年 linhan. All rights reserved.
//

import UIKit

struct Country
{
    var name:String
    var id:String
    var englishName:String?
    var likes:Int?
    var thumbURL:String?
    init(name:String, id:String, englishName:String? = nil, likes:Int? = nil, thumbURL:String? = nil)
    {
        self.name = name
        self.id = id
        self.englishName = englishName
        self.likes = likes
        self.thumbURL = thumbURL
    }
}

class DestinationViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    
    
    private struct Category
    {
        var name:String
        var code:Int
        var hot:Bool
        var countries:[Country]
    }
    
    private struct Continent
    {
        var name:String
        var code:Int
        var categories:[Category]
    }
    
    private var _loaded:Bool = false
    
    //当前选中的洲
    private var _selectedContinentIndex:Int = 0
    
    private var _data:[Continent] = []
    
    private var _continentTableView:UITableView?
    
    private var _countryTableView:UITableView?
    
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
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        if !_loaded
        {
            loadData()
        }
    }
    
    override func viewWillDisappear(animated: Bool)
    {
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
        self.view.backgroundColor = UIColor.whiteColor()
        
        let tableViewY:CGFloat = AppConfig.shared().statusBarHeight + AppConfig.shared().navigationBarHeight
        let tableViewHeight:CGFloat = self.view.height - tableViewY - AppConfig.shared().tabBarHeight
        _continentTableView = UITableView()
        _continentTableView!.frame = CGRectMake(0, tableViewY, 90, tableViewHeight)
        _continentTableView!.tableFooterView = UIView()
        _continentTableView!.registerClass(UITableViewCell.self, forCellReuseIdentifier: "continentCell")
        _continentTableView!.dataSource = self
        _continentTableView!.delegate = self
        self.view.addSubview(_continentTableView!)
        
        
        _countryTableView = UITableView()
        _countryTableView!.frame = CGRectMake(100, tableViewY, self.view.width - 100, tableViewHeight)
        _countryTableView!.tableFooterView = UIView()
        _countryTableView!.separatorStyle = .None
        _countryTableView!.registerClass(UITableViewCell.self, forCellReuseIdentifier: "countryCell")
        _countryTableView!.dataSource = self
        _countryTableView!.delegate = self
        self.view.addSubview(_countryTableView!)
        
    }
    
    private func loadData()
    {
        var data:NSData?
        //先从缓存中加载
        var cacheDataPath:String = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as String
        cacheDataPath += "/all_country.json"
        if NSFileManager.defaultManager().fileExistsAtPath(cacheDataPath)
        {
            println("先从缓存中加载")
            data = NSData(contentsOfFile: cacheDataPath)
            dispatch_async(dispatch_get_main_queue(),
                {
                    
            })
        }
        if data != nil
        {
            parseData(data!)
            return
        }
        
        //缓存中没有，则从安装包中加载
        var bundlePath:String? = NSBundle.mainBundle().pathForResource("all_country", ofType: "json")
        if bundlePath != nil
        {
            println("从安装包中加载")
            data = NSData(contentsOfFile: bundlePath!)
            dispatch_async(dispatch_get_main_queue(),
                {
                    
            })
        }
        
        if data != nil
        {
            parseData(data!)
            NSFileManager.defaultManager().createFileAtPath(cacheDataPath, contents:data! ,attributes:nil)
            return
        }
        
        //缓存以及安装包中均没有，则在线加载
        loadDataRemote()
    }
    
    //加载商品列表
    private func loadDataRemote()
    {
        incrementProgressView?.start()
        //self._incrementProgressView!.finish()
        var url:String = "http://open.qyer.com/place/common/get_all_country?client_id=qyer_ios&client_secret=cd254439208ab658ddf9&v=1&track_user_id=2061877&track_deviceid=14F93361-1204-496C-8444-78059A841B4F&track_app_version=5.4.4&track_app_channel=App%20Store&track_device_info=iPhone%205s&track_os=ios%207.1.2&lat=35.716210&lon=139.786830&oauth_token=4de3ee300e936008c61f6b9c0f175257&app_installtime=1419754055"
        WebLoader.load(url, completionHandler: {(data:NSData!) in
            
            if data != nil
            {
                self.parseData(data!)
            }
            self.incrementProgressView?.finish()
            
            }, errorHandler: {(error:NSError) in
                
                //self.incrementProgressView?.finish()
        })
    }
    
    
    //解析数据
    private func parseData(data:NSData)
    {
        self._loaded = true
        let json = JSON(data: data)
        if let status = json["status"].integerValue
        {
            if status == 1
            {
                _data.removeAll()
                if let continents = json["data"].arrayValue
                {
                    //洲
                    for i in 0..<continents.count
                    {
                        var hotCountries:[Country] = []
                        var normalCountries:[Country] = []
                        //热门国家
                        if let hotCountryList = continents[i]["hotcountrylist"].arrayValue
                        {
                            for j in 0..<hotCountryList.count
                            {
                                var id:Int = hotCountryList[j]["pid"].integerValue ?? 0
                                hotCountries.append(Country(name: hotCountryList[j]["catename"].stringValue ?? "", id: "\(id)", englishName:hotCountryList[j]["catename_en"].stringValue, likes:hotCountryList[j]["count"].integerValue, thumbURL:hotCountryList[j]["photo"].stringValue))
                            }
                        }
                        
                        //其他国家
                        if let normalCountryList = continents[i]["countrylist"].arrayValue
                        {
                            for j in 0..<normalCountryList.count
                            {
                                var id:Int = normalCountryList[j]["pid"].integerValue ?? 0
                                normalCountries.append(Country(name: normalCountryList[j]["catename_en"].stringValue ?? normalCountryList[j]["catename"].stringValue ?? "", id: "\(id)"))
                            }
                        }
                        
                        var hotCategory:Category = Category(name: "热门", code: 0, hot: true, countries: hotCountries)
                        var normalCategory:Category = Category(name: "其他", code: 0, hot: false, countries: normalCountries)
                        var continent:Continent = Continent(name: continents[i]["catename"].stringValue ?? "", code: continents[i]["id"].integerValue ?? -1, categories: [hotCategory, normalCategory])
                        _data.append(continent)
                    }
                    
                    dispatch_async(dispatch_get_main_queue(),
                        {
                            self._continentTableView?.reloadData()
                            self._selectedContinentIndex = 1
                            self._continentTableView!.selectRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0), animated: false, scrollPosition: UITableViewScrollPosition.None)
                            self._countryTableView?.reloadData()
                            
                    })
                    
                }
            }
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        var number:Int = tableView == _continentTableView ? 1 : (_data.count == 0 ? 1 : _data[_selectedContinentIndex].categories.count)
        return number
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        var title:String?
        if _data.count > 0
        {
            title = tableView == _continentTableView ? nil : _data[_selectedContinentIndex].categories[section].name
        }
        return title
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        var number:Int = 0
        if _data.count != 0
        {
            number = tableView == _countryTableView ? _data[_selectedContinentIndex].categories[section].countries.count : _data.count
        }
        return number
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        var height:CGFloat = 0
        if _data.count != 0
        {
            height = tableView == _continentTableView ? 44 : (_data[_selectedContinentIndex].categories[indexPath.section].hot ? 160 : 40)
        }
        return height
    }
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell:UITableViewCell
        var index:Int = indexPath.row
        var section:Int = indexPath.section
        var label:String = ""
        
        if tableView == _continentTableView
        {
            cell = tableView.dequeueReusableCellWithIdentifier("continentCell") as UITableViewCell
            if index >= 0 && index < _data.count
            {
                label = _data[index].name
            }
            cell.textLabel!.text = label
        }
        else
        {
            cell = tableView.dequeueReusableCellWithIdentifier("countryCell") as UITableViewCell
            //cell.contentView.backgroundColor = UIColor(white: 0.85, alpha: 1)
            if _selectedContinentIndex >= 0 && _selectedContinentIndex < _data.count && section >= 0 && section < _data[_selectedContinentIndex].categories.count && index >= 0 && index < _data[_selectedContinentIndex].categories[section].countries.count
            {
                var category = _data[_selectedContinentIndex].categories[section]
                if category.hot
                {
                    var hotCell:HotPlaceCell? = tableView.dequeueReusableCellWithIdentifier("HotPlaceCell") as? HotPlaceCell
                    if hotCell == nil
                    {
                        hotCell = HotPlaceCell(style: UITableViewCellStyle.Default, reuseIdentifier: "HotPlaceCell", cellWidth: _countryTableView!.width)
                    }
                    hotCell!.place = _data[_selectedContinentIndex].categories[section].countries[index]
                    cell = hotCell!
                    cell.selectionStyle = .None
                }
                else
                {
                    //cell.contentView.backgroundColor = UIColor(white: 200 / 255, alpha: 1)
                    label = _data[_selectedContinentIndex].categories[section].countries[index].name
                    cell.textLabel!.text = label
                    cell.selectionStyle = .Default
                }
            }
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if tableView == _continentTableView
        {
            _selectedContinentIndex = indexPath.row
            _countryTableView!.reloadData()
            _countryTableView!.setContentOffset(CGPointMake(0, 0), animated: false)
        }
        else
        {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            var index:Int = indexPath.row
            var section:Int = indexPath.section
            if _selectedContinentIndex >= 0 && _selectedContinentIndex < _data.count && section >= 0 && section < _data[_selectedContinentIndex].categories.count && index >= 0 && index < _data[_selectedContinentIndex].categories[section].countries.count
            {
                var country:Country = _data[_selectedContinentIndex].categories[section].countries[index]
                if country.id != ""
                {
                    var countryProfileViewController:CountryProfileViewController = CountryProfileViewController()
                    countryProfileViewController.countryID = country.id
                    countryProfileViewController.title = country.name
                    self.navigationController!.pushViewController(countryProfileViewController, animated: true)
                }
                
            }
            
            
            //_countryTableView!.reloadRowsAtIndexPaths(paths, withRowAnimation : UITableViewRowAnimation.None)
            
        }
        
    }
    
    
    
    

    
    
    
    
    
    


}//end class

