//
//  EssenceJournalCell.swift
//  QYer
//
//  Created by linhan on 15-4-16.
//  Copyright (c) 2015年 linhan. All rights reserved.
//

import Foundation
import UIKit
class POICell: UITableViewCell {
    
    var data:POI?
    
    private var _cellWidth:CGFloat = 0
    private var _change:Bool = true
    
    //内容间垂直间隔
    private let VerticalGap:CGFloat = 10
    
    private let ContentEdgeInsets:UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
    
    private var _contentContainer:UIView = UIView()
    private var _coverImageView:ImageLoader?
    lazy private var _titleLabel:UILabel = UILabel()
    lazy private var _locationLabel:UILabel = UILabel()
    lazy private var _captionLabel:UILabel = UILabel()
    
    init(style: UITableViewCellStyle, reuseIdentifier: String?, cellWidth:CGFloat)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        _cellWidth = cellWidth
        setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup()
    {
        self.selectionStyle = .None
        self.backgroundColor = UIColor.clearColor()
        
        _contentContainer.backgroundColor = UIColor.whiteColor()
        _contentContainer.layer.borderColor = UIColor(white: 220 / 255, alpha: 1).CGColor
        _contentContainer.layer.borderWidth = 0.5
        self.contentView.addSubview(_contentContainer)
        
        //封面
        _coverImageView = ImageLoader(frame: CGRectMake(10, 10, _cellWidth - 20, 130))
        _coverImageView!.completeCallback = imageLoadedCompleteCallback
        _contentContainer.addSubview(_coverImageView!)
        
        //灰色过度
        var maskImageView:UIImageView = UIImageView(image:UIImage(named:"image_mask"))
        var maskHeight:CGFloat = maskImageView.height * (_coverImageView!.width / maskImageView.width)
        maskImageView.frame = CGRectMake(_coverImageView!.x, _coverImageView!.bottom - maskHeight, _coverImageView!.width, maskHeight)
        _contentContainer.addSubview(maskImageView)
        
        //向右箭头
        var arrow:UIImageView = UIImageView(image:UIImage(named:"arrow_mguide.png"))
        arrow.frame = CGRectMake(_coverImageView!.right - arrow.width - 10, _coverImageView!.bottom - arrow.height - 10, arrow.width, arrow.height)
        _contentContainer.addSubview(arrow)
        
        //place_poi@2x
        var locationImageView:UIImageView = UIImageView(image:UIImage(named:"place_poi"))
        locationImageView.frame = CGRectMake(20, 95, locationImageView.width, locationImageView.height)
        _contentContainer.addSubview(locationImageView)
        
        //标题
        _titleLabel.frame = CGRectMake(locationImageView.right, 95, _coverImageView!.width - 40, 20)
        _titleLabel.font = UIFont.systemFontOfSize(18)
        _titleLabel.textColor = UIColor.whiteColor()
        _titleLabel.shadowColor = UIColor.blackColor()
        _titleLabel.shadowOffset = CGSizeMake(1, 1)
        self._contentContainer.addSubview(_titleLabel)
        
        //位置
        _locationLabel.frame = CGRectMake(20, _titleLabel.bottom, _titleLabel.width, 16)
        _locationLabel.font = UIFont.systemFontOfSize(12)
        _locationLabel.textColor = UIColor.whiteColor()
        _locationLabel.shadowColor = UIColor.blackColor()
        _locationLabel.shadowOffset = CGSizeMake(1, 1)
        self._contentContainer.addSubview(_locationLabel)
        
        let CaptionLabelY:CGFloat = 150
        _captionLabel.frame = CGRectMake(10, CaptionLabelY, _coverImageView!.width, 20)
        _captionLabel.numberOfLines = 0
        _captionLabel.font = UIFont.systemFontOfSize(14)
        _captionLabel.textColor = UIColor.darkGrayColor()
        self._contentContainer.addSubview(_captionLabel)
    }
    
    override func prepareForReuse()
    {
        super.prepareForReuse()
        
        _change = true
    }
    
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        if data != nil && _change
        {
            _change = false
            
            
            _coverImageView!.image = nil
            if data!.coverURL != nil
            {
                _coverImageView!.load(data!.coverURL!)
            }
            
            _titleLabel.text = data!.chineseName ?? ""
            _locationLabel.text = (data!.countryName ?? "") + "，" + (data!.cityName ?? "")
            
            var description:String = data!.POIDescription ?? ""
            var descriptionHeight:CGFloat = StringUtil.getStringHeight(description, font: self._captionLabel.font, width: self._captionLabel.width)
            self._captionLabel.height = descriptionHeight
            self._captionLabel.text = description
            
            _contentContainer.frame = CGRectMake(ContentEdgeInsets.left, ContentEdgeInsets.top, _cellWidth - ContentEdgeInsets.left - ContentEdgeInsets.right, self._captionLabel.bottom + 20)
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
    
    class func getCellHeight(cellWidth:CGFloat, text:String)->CGFloat
    {
        var height:CGFloat = 0
        let CaptionLabelY:CGFloat = 150
        var textHeight:CGFloat = StringUtil.getStringHeight(text, font: UIFont.systemFontOfSize(14), width: cellWidth - 20)
        height = CaptionLabelY + textHeight + 30
        return height
    }
    
}