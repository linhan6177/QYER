//
//  JournalCell.swift
//  QYer
//
//  Created by linhan on 15-4-6.
//  Copyright (c) 2015年 linhan. All rights reserved.
//

import Foundation
import UIKit
class TravelPlaceCell: UITableViewCell
{
    var data:Place?
    
    private var _cellWidth:CGFloat = 0
    private var _change:Bool = true
    
    //内容间垂直间隔
    private let VerticalGap:CGFloat = 10
    
    private let ContentEdgeInsets:UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    
    private var _avatarImageView:ImageLoader?
    private var _titleLabel: UILabel?
    lazy private var _numberLabel: UILabel = UILabel()
    lazy private var _mguideImageView:UIImageView = UIImageView(image: UIImage(named:"has_MicroGuide"))
    
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
        
        //微锦囊
        _mguideImageView.frame = CGRectMake(titleLabelX, _numberLabel.bottom + 5, _mguideImageView.width, _mguideImageView.height)
        _mguideImageView.hidden = true
        self.contentView.addSubview(_mguideImageView)
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
            var beenCount:Int = data!.beenCount ?? 0
            _titleLabel?.text = data!.name ?? ""
            _numberLabel.text = "\(beenCount) 人去过"
            _mguideImageView.hidden = data!.mguide ?? true
        }
    }
}