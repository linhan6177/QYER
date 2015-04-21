//
//  JournalCell.swift
//  QYer
//
//  Created by linhan on 15-4-6.
//  Copyright (c) 2015年 linhan. All rights reserved.
//

import Foundation
import UIKit
class JournalCell: UITableViewCell
{
    var journal:Journal?
    
    private var _cellWidth:CGFloat = 0
    private var _change:Bool = true
    
    //内容间垂直间隔
    private let VerticalGap:CGFloat = 10
    
    private let ContentEdgeInsets:UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    
    private var _avatarImageView:ImageLoader?
    private var _titleLabel: UILabel?
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
        
        //昵称
        let titleLabelX:CGFloat = _avatarImageView!.x + _avatarImageView!.width + 20
        _titleLabel = UILabel(frame: CGRectMake(titleLabelX, 5, _cellWidth - titleLabelX - ContentEdgeInsets.right, 45))
        _titleLabel!.numberOfLines = 0
        _titleLabel!.font = UIFont.systemFontOfSize(17)
        self.contentView.addSubview(_titleLabel!)
        
        //时间
        let TimeLableWidth:CGFloat = 100
        _timeLabel = UILabel(frame: CGRectMake(titleLabelX, 50, _titleLabel!.width, 21))
        _timeLabel!.textColor = UIColor(white: 180 / 255, alpha: 1)
        _timeLabel!.font = UIFont.systemFontOfSize(15)
        _timeLabel!.lineBreakMode = NSLineBreakMode.ByTruncatingMiddle
        self.contentView.addSubview(_timeLabel!)
        
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
            
            _avatarImageView!.image = nil
            if journal!.thumbURL != nil
            {
                _avatarImageView!.load(journal!.thumbURL!)
            }
            
            _titleLabel?.text = journal!.title ?? ""
            _timeLabel?.text = (journal!.name != nil ? journal!.name! + " | " : "") + (journal!.date ?? "")
            
        }
    }
}