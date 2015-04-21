//
//  EssenceJournalCell.swift
//  QYer
//
//  Created by linhan on 15-4-16.
//  Copyright (c) 2015年 linhan. All rights reserved.
//

import Foundation
import UIKit
class MicroBookCell: UITableViewCell {
    
    var journal:Journal?
    
    let CellHeight:CGFloat = 270
    
    private var _cellWidth:CGFloat = 0
    private var _change:Bool = true
    
    //内容间垂直间隔
    private let VerticalGap:CGFloat = 10
    
    private let ContentEdgeInsets:UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
    
    private var _contentContainer:UIView = UIView()
    private var _coverImageView:ImageLoader?
    private var _avatarImageView:ImageLoader?
    lazy private var _countLabel:UILabel = UILabel()
    lazy private var _titleLabel:UILabel = UILabel()
    lazy private var _nameLabel:UILabel = UILabel()
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
        self.backgroundColor = UIColor.clearColor()
        
        _contentContainer.backgroundColor = UIColor.whiteColor()
        _contentContainer.layer.borderColor = UIColor(white: 220 / 255, alpha: 1).CGColor
        _contentContainer.layer.borderWidth = 0.5
        _contentContainer.frame = CGRectMake(ContentEdgeInsets.left, ContentEdgeInsets.top * 0.5, _cellWidth - ContentEdgeInsets.left - ContentEdgeInsets.right, CellHeight - ContentEdgeInsets.bottom)
        self.contentView.addSubview(_contentContainer)
        
        //封面
        _coverImageView = ImageLoader(frame: CGRectMake(0, 0, _contentContainer.width, 190))
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
        
        _countLabel.backgroundColor = UIColor(white: 0, alpha: 0.5)
        _countLabel.textColor = UIColor.whiteColor()
        _countLabel.font = UIFont.systemFontOfSize(13)
        _countLabel.text = " 10个旅行地 "
        _countLabel.textAlignment = .Center
        _countLabel.sizeToFit()
        _countLabel.frame = CGRectMake(_contentContainer.width - _countLabel.width - 20, 10, _countLabel.width, _countLabel.height)
        _contentContainer.addSubview(_countLabel)
        
        //标题
        let titleLabelX:CGFloat = _avatarImageView!.x + _avatarImageView!.width + 16
        _titleLabel.frame = CGRectMake(titleLabelX, _avatarImageView!.y, _contentContainer.width - titleLabelX - 10, 20)
        _titleLabel.font = UIFont.systemFontOfSize(15)
        _titleLabel.textColor = UIColor.whiteColor()
        self._contentContainer.addSubview(_titleLabel)
        
        //时间
        _nameLabel.frame = CGRectMake(titleLabelX, _titleLabel.bottom + 5, _contentContainer.width * 0.5, 18)
        _nameLabel.font = UIFont.systemFontOfSize(12)
        _nameLabel.textColor = UIColor.whiteColor()
        self._contentContainer.addSubview(_nameLabel)
        
        _captionLabel.frame = CGRectMake(10, _coverImageView!.height, _contentContainer.width - 20, _contentContainer.height - _coverImageView!.height)
        _captionLabel.numberOfLines = 3
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
        
        if journal != nil && _change
        {
            _change = false
            
            
            _coverImageView!.image = nil
            if journal!.thumbURL != nil
            {
                _coverImageView!.load(journal!.thumbURL!)
            }
            
            _avatarImageView!.image = nil
            if journal!.avatarURL != nil
            {
                _avatarImageView!.load(journal!.avatarURL!)
            }
            
            _countLabel.text = " \(journal!.placeCount ?? 0)个旅行地 "
            _titleLabel.text = journal!.title ?? ""
            _nameLabel.text = journal!.name ?? ""
            _captionLabel.text = journal!.caption ?? ""
            
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