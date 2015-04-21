//
//  POIBasicInfoCell.swift
//  QYer
//
//  Created by linhan on 15-4-19.
//  Copyright (c) 2015年 linhan. All rights reserved.
//

import Foundation
import UIKit
class POIBasicInfoCell: UIView
{
    private let ContentEdgeInsets:UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    private var _imageView:UIImageView
    private var _titleLabel:UILabel = UILabel()
    private var _contentLabel:UILabel = UILabel()
    init(width:CGFloat, image:UIImage?, title:String?, content:String?)
    {
        _imageView = UIImageView(frame: CGRectMake(ContentEdgeInsets.left, ContentEdgeInsets.top * 0.5, 24, 24))
        _imageView.image = image
        _imageView.contentMode = .ScaleAspectFill
        
        _titleLabel.frame = CGRectMake(_imageView.right + 20, ContentEdgeInsets.top, 50, 17)
        _titleLabel.font = UIFont.systemFontOfSize(13)
        _titleLabel.textColor = UIColor.darkGrayColor()
        _titleLabel.text = title
        
        let ContentLabelX:CGFloat = _titleLabel.right + 10
        _contentLabel.frame = CGRectMake(ContentLabelX, ContentEdgeInsets.top, width - ContentLabelX - ContentEdgeInsets.right, 17)
        _contentLabel.font = UIFont.systemFontOfSize(13)
        _contentLabel.textColor = UIColor.darkGrayColor()
        _contentLabel.numberOfLines = 0
        _contentLabel.text = content
        var contentHeight:CGFloat = StringUtil.getStringHeight(content ?? "", font: _contentLabel.font, width: _contentLabel.width)
        _contentLabel.height = contentHeight
        
        var rect:CGRect = CGRectMake(0, 0, width, _contentLabel.bottom + ContentEdgeInsets.bottom)
        
        super.init(frame: rect)
        self.backgroundColor = UIColor.whiteColor()
        self.addSubview(_imageView)
        self.addSubview(_titleLabel)
        self.addSubview(_contentLabel)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    
    
    
}