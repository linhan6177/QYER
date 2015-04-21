//
//  PhotoListViewController.swift
//  QYer
//
//  Created by linhan on 15-4-18.
//  Copyright (c) 2015年 linhan. All rights reserved.
//

import Foundation
import UIKit
class Photo:PhotoItem
{
    var thumbURL:String?
    var authorName:String?
}
class PhotoListViewController:UIViewController,UICollectionViewDataSource,UICollectionViewDelegate
{
    var id:String = ""
    
    //照片总数
    var totalPhotos:Int = 0
    
    
    private var _appearedFirstTime:Bool = false
    
    private var _photos:[Photo] = []
    //已经加载的页数
    private var _loadedPage:Int = 1
    
    private var _headerRefreshing:Bool = false
    
    private var _setupedRefresh:Bool = false
    
    private var _numPhotoPerScreen:Int = 0
    
    private var _collectionView:UICollectionView?
    
    
    lazy var photoViewer:PhotoViewer = PhotoViewer()
    
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
        
        let numOfHorizontal:Int = 4
        let Grid:CGFloat = 5
        var cellWidth:CGFloat = (self.view.width - (CGFloat(numOfHorizontal + 1) * Grid)) / CGFloat(numOfHorizontal)
        var layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSizeMake(cellWidth, cellWidth);
        //横向最小间隔
        layout.minimumInteritemSpacing = Grid;
        //纵向最小间隔
        layout.minimumLineSpacing = Grid;
        layout.sectionInset = UIEdgeInsetsMake(Grid, Grid, Grid, Grid)
        
        _numPhotoPerScreen = Int(ceil(self.view.height / cellWidth)) * numOfHorizontal
        
        //let TableViewY:CGFloat = PullDownBtnBGView.bottom + 5
        _collectionView = UICollectionView(frame: CGRectMake(0, 0, self.view.width, self.view.height), collectionViewLayout: layout)
        _collectionView!.backgroundColor = UIColor(white: 230 / 250, alpha: 1)
        _collectionView!.registerClass(PhotoCollectionCell.self, forCellWithReuseIdentifier: "PhotoCollectionCell")
        _collectionView!.dataSource = self
        _collectionView!.delegate = self
        self.view.addSubview(_collectionView!)
    }
    
    func setupRefresh()
    {
        //上刷新取更多
        
        self._collectionView!.addFooterWithCallback({
            
            self._headerRefreshing = false
            self._loadedPage = self._loadedPage + 1
            self.loadData(page: self._loadedPage)
            
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
    private func loadData(page:Int = 1)
    {
        self.incrementProgressView?.start()
        
        var url:String = "http://open.qyer.com/place/common/get_photo_list?client_id=qyer_ios&client_secret=cd254439208ab658ddf9&type=poi&objectid=\(id)&pagesize=\(_numPhotoPerScreen)&page=\(page)&screensize=640"
        
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
                if let photos = json["data"].arrayValue
                {
                    for i in 0..<photos.count
                    {
                        var photo:Photo = Photo()
                        photo.thumbURL = photos[i]["small_photourl"].stringValue
                        photo.largeImageURL = photos[i]["photourl"].stringValue
                        photo.authorName = photos[i]["username"].stringValue
                        
                        _photos.append(photo)
                    }
                }
                
                
                if self._photos.count < self.totalPhotos && !self._setupedRefresh
                {
                    _setupedRefresh = true
                    self.setupRefresh()
                }
                if _photos.count > 0
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
        return _photos.count
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        var cell:PhotoCollectionCell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCollectionCell", forIndexPath: indexPath) as PhotoCollectionCell
        var index:Int = indexPath.row
        if index >= 0 && index < _photos.count
        {
            var photo:Photo = _photos[index]
            cell.data = photo
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        var index:Int = indexPath.row
        if index >= 0 && index < _photos.count
        {
            var photo:Photo = _photos[index]
            var photoCell:PhotoCollectionCell? = collectionView.cellForItemAtIndexPath(indexPath) as? PhotoCollectionCell
            
            if photoCell != nil
            {
                var startFrame:CGRect = photoCell!.thumbImageView.superview!.convertRect(photoCell!.thumbImageView.frame, toView:self.view)
                var thumbImage:UIImage? = photoCell?.thumbImageView.image
                
                photo.thumbImage = thumbImage
                _photos[index] = photo
                
                photoViewer.startFrame = startFrame
                //photoViewer.images = _photos
                //photoViewer.startIndex = indexPath.row
                photoViewer.show(_photos, index: indexPath.row)
                self.presentViewController(photoViewer, animated: false, completion: nil)
                
            }
            
            //var cell:ItemCell? = tableView.cellForRowAtIndexPath(indexPath) as? ItemCell
            
        }
    }
    
    
    
    
    
    
}//end class