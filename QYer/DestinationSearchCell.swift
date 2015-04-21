//
//  JournalCell.swift
//  QYer
//
//  Created by linhan on 15-4-6.
//  Copyright (c) 2015年 linhan. All rights reserved.
//

import Foundation
import UIKit
class DestinationSearchCell: UITableViewCell
{
    var data:POISearchData?
    
    private var _cellWidth:CGFloat = 0
    private var _change:Bool = true
    
    //内容间垂直间隔
    private let VerticalGap:CGFloat = 10
    
    private let ContentEdgeInsets:UIEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 10)
    
    private var _avatarImageView:ImageLoader?
    
    private var _titleLabel: UILabel?
    lazy private var _typeLabel: UILabel = UILabel()
    lazy private var _numberLabel: UILabel = UILabel()
    lazy private var _zoneLabel: UILabel = UILabel()
    
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
        //selectionStyle = .None
        
        //头像
        _avatarImageView = ImageLoader(frame: CGRectMake(ContentEdgeInsets.left, ContentEdgeInsets.top, 100, 60))
        self.contentView.addSubview(_avatarImageView!)
        
        //标题
        let titleLabelX:CGFloat = _avatarImageView!.x + _avatarImageView!.width + 20
        _titleLabel = UILabel(frame: CGRectMake(titleLabelX, 5, _cellWidth - titleLabelX - ContentEdgeInsets.right, 20))
        _titleLabel!.font = UIFont.systemFontOfSize(17)
        self.contentView.addSubview(_titleLabel!)
        
        //类型
        _typeLabel.text = "旅行地"
        _typeLabel.textColor = UIColor.greenColor()
        _typeLabel.font = UIFont.systemFontOfSize(12)
        _typeLabel.textAlignment = .Right
        _typeLabel.sizeToFit()
        _typeLabel.frame = CGRectMake(_cellWidth - ContentEdgeInsets.right - _typeLabel.width, 30, _typeLabel.width, _typeLabel.height)
        _typeLabel.text = ""
        self.contentView.addSubview(_typeLabel)
        
        //区域
        _zoneLabel.frame = CGRectMake(titleLabelX, 30, _typeLabel.x - titleLabelX , 20)
        _zoneLabel.textColor = UIColor.lightGrayColor()
        _zoneLabel.font = UIFont.systemFontOfSize(12)
        self.contentView.addSubview(_zoneLabel)
        
        //人数
        _numberLabel.frame = CGRectMake(titleLabelX, 45, _titleLabel!.width, 20)
        _numberLabel.textColor = UIColor.lightGrayColor()
        _numberLabel.font = UIFont.systemFontOfSize(12)
        self.contentView.addSubview(_numberLabel)
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
            
            _avatarImageView!.image = nil
            if data!.thumbURL != nil
            {
                _avatarImageView!.load(data!.thumbURL!)
            }
            
            var parentParentName:String = data!.parentParentName ?? ""
            _titleLabel?.text = data!.name ?? ""
            _typeLabel.text = data!.typeLabel ?? ""
            _zoneLabel.text = (data!.parentName ?? "") + (parentParentName != "" ? "/\(parentParentName)" : "")
            _numberLabel.text = "\(data!.beenCount ?? 0) 人去过"
        }
    }
}