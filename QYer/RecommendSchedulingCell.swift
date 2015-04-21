//
//  EssenceJournalCell.swift
//  QYer
//
//  Created by linhan on 15-4-16.
//  Copyright (c) 2015年 linhan. All rights reserved.
//

import Foundation
import UIKit
class RecommendSchedulingCell: UITableViewCell {
    
    var data:Scheduling?
    
    let CellHeight:CGFloat = 200
    
    private var _cellWidth:CGFloat = 0
    private var _change:Bool = true
    
    //内容间垂直间隔
    private let VerticalGap:CGFloat = 10
    
    private let ContentEdgeInsets:UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    
    private var _contentContainer:UIView = UIView()
    private var _coverImageView:ImageLoader?
    private var _avatarImageView:ImageLoader?
    lazy private var _titleLabel:UILabel = UILabel()
    lazy private var _nameLabel:UILabel = UILabel()
    lazy private var _routeLabel:UILabel = UILabel()
    lazy private var _daysLabel:UILabel = UILabel()
    
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
        self.backgroundColor = UIColor.clearColor()
        selectionStyle = .None
        
        _contentContainer.backgroundColor = UIColor.whiteColor()
        _contentContainer.layer.borderColor = UIColor(white: 220 / 255, alpha: 1).CGColor
        _contentContainer.layer.borderWidth = 0.5
        _contentContainer.layer.cornerRadius = 5
        _contentContainer.layer.masksToBounds = true
        _contentContainer.frame = CGRectMake(ContentEdgeInsets.left, ContentEdgeInsets.top * 0.5, _cellWidth - ContentEdgeInsets.left - ContentEdgeInsets.right, CellHeight - (ContentEdgeInsets.top * 0.5) - (ContentEdgeInsets.bottom * 0.5))
        self.contentView.addSubview(_contentContainer)
        
        //封面
        _coverImageView = ImageLoader(frame: CGRectMake(0, 0, _contentContainer.width, 150))
        _coverImageView!.completeCallback = imageLoadedCompleteCallback
        _contentContainer.addSubview(_coverImageView!)
        
        //灰色过度
        var maskImageView:UIImageView = UIImageView(image:UIImage(named:"image_mask"))
        var maskHeight:CGFloat = maskImageView.height * (_coverImageView!.width / maskImageView.width)
        maskImageView.frame = CGRectMake(_coverImageView!.x, _coverImageView!.bottom - maskHeight, _coverImageView!.width, maskHeight)
        _contentContainer.addSubview(maskImageView)
        
        
        //头像
        _avatarImageView = ImageLoader(frame: CGRectMake(10, _coverImageView!.height - 50, 40, 40))
        _avatarImageView!.layer.cornerRadius = _avatarImageView!.width * 0.5
        _avatarImageView!.layer.masksToBounds = true
        //_avatarImageView?.layer.shouldRasterize = true
        _contentContainer.addSubview(_avatarImageView!)
        
        var circle:UIImageView = UIImageView(image:UIImage(named: "bg_days"))
        circle.frame = CGRectMake(_contentContainer.width - circle.width - 10, 10, circle.width, circle.height)
        _contentContainer.addSubview(circle)
        
        //天数
        _daysLabel.frame = CGRectMake(circle.x, circle.y + ((circle.height - 20) * 0.5), circle.width, 20)
        _daysLabel.textColor = UIColor.whiteColor()
        _daysLabel.textAlignment = .Center
        _daysLabel.font = UIFont.systemFontOfSize(16)
        _contentContainer.addSubview(_daysLabel)
        
        
        //标题
        let titleLabelX:CGFloat = _avatarImageView!.x + _avatarImageView!.width + 16
        _titleLabel.frame = CGRectMake(titleLabelX, _avatarImageView!.y - 5, _contentContainer.width - titleLabelX - ContentEdgeInsets.right, 22)
        _titleLabel.font = UIFont.systemFontOfSize(15)
        _titleLabel.textColor = UIColor.whiteColor()
        _titleLabel.shadowColor = UIColor.blackColor()
        _titleLabel.shadowOffset = CGSizeMake(1, 1)
        self._contentContainer.addSubview(_titleLabel)
        
        //昵称
        let TimeLableWidth:CGFloat = 100
        _nameLabel.frame = CGRectMake(titleLabelX, _titleLabel.bottom + 5, _contentContainer.width * 0.5, 16)
        _nameLabel.font = UIFont.systemFontOfSize(12)
        _nameLabel.textColor = UIColor.whiteColor()
        _nameLabel.shadowColor = UIColor.blackColor()
        _nameLabel.shadowOffset = CGSizeMake(1, 1)
        self._contentContainer.addSubview(_nameLabel)
        
        _routeLabel.frame = CGRectMake(_avatarImageView!.x, _coverImageView!.bottom + 10,  _contentContainer.width - 20, 18)
        _routeLabel.font = UIFont.systemFontOfSize(15)
        _routeLabel.textColor = UIColor.blackColor()
        self._contentContainer.addSubview(_routeLabel)
        
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
            
            _avatarImageView!.image = nil
            if data!.avatarURL != nil
            {
                _avatarImageView!.load(data!.avatarURL!)
            }
            
            _titleLabel.text = data!.title ?? ""
            _nameLabel.text = data!.authorName ?? ""
            _routeLabel.text = data!.route ?? ""
            _daysLabel.text = "\(data!.dayCount ?? 0)天"
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
    
}