//
//  JournalCell.swift
//  QYer
//
//  Created by linhan on 15-4-6.
//  Copyright (c) 2015年 linhan. All rights reserved.
//

import Foundation
import UIKit
class CityCell: UITableViewCell
{
    var city:City?
    
    private var _cellWidth:CGFloat = 0
    private var _change:Bool = true
    
    //内容间垂直间隔
    private let VerticalGap:CGFloat = 10
    
    private let ContentEdgeInsets:UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    
    private var _avatarImageView:ImageLoader?
    private var _titleLabel: UILabel?
    lazy private var _numberLabel: UILabel = UILabel()
    lazy private var _zoneLabel: UILabel = UILabel()
    private var _timeLabel:UILabel?
    
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
        //_avatarImageView?.layer.shouldRasterize = true
        self.contentView.addSubview(_avatarImageView!)
        
        //
        let titleLabelX:CGFloat = _avatarImageView!.x + _avatarImageView!.width + 20
        _titleLabel = UILabel(frame: CGRectMake(titleLabelX, 5, _cellWidth - titleLabelX - ContentEdgeInsets.right, 20))
        _titleLabel!.font = UIFont.systemFontOfSize(17)
        self.contentView.addSubview(_titleLabel!)
        
        //人数
        _numberLabel.frame = CGRectMake(titleLabelX, 25, _titleLabel!.width, 20)
        _numberLabel.textColor = UIColor.lightGrayColor()
        _numberLabel.font = UIFont.systemFontOfSize(12)
        self.contentView.addSubview(_numberLabel)
        
        //热门经典
        _zoneLabel.frame = CGRectMake(titleLabelX, 45, _titleLabel!.width, 30)
        _zoneLabel.textColor = UIColor.lightGrayColor()
        _zoneLabel.font = UIFont.systemFontOfSize(12)
        _zoneLabel.numberOfLines = 2
        self.contentView.addSubview(_zoneLabel)
    }
    
    override func prepareForReuse()
    {
        super.prepareForReuse()
        
        _change = true
    }
    
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        if city != nil && _change
        {
            _change = false
            
            _avatarImageView!.image = nil
            if city!.thumbURL != nil
            {
                _avatarImageView!.load(city!.thumbURL!)
            }
            
            _titleLabel?.text = city!.name ?? city!.englishName ?? ""
            _numberLabel.text = "\(city!.beenNumber) 人去过"
            _zoneLabel.text = city!.representative ?? ""
        }
    }
}