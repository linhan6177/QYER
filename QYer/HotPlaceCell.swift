//
//  HotPlaceCell.swift
//  QYer
//
//  Created by linhan on 15-4-7.
//  Copyright (c) 2015年 linhan. All rights reserved.
//

import Foundation
import UIKit
class HotPlaceCell: UITableViewCell
{
    var place:Country?
    
    let CellHeight:CGFloat = 150
    
    private var _cellWidth:CGFloat = 0
    private var _change:Bool = true
    
    //内容间垂直间隔
    private let VerticalGap:CGFloat = 10
    
    private let ContentEdgeInsets:UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    
    private var _thumbView:ImageLoader?
    
    private var _likesLabel:UILabel = UILabel()
    private var _nameLabel:UILabel = UILabel()
    private var _englishNameLabel:UILabel = UILabel()

    private var _contentContainer:UIView = UIView()
    
    
    
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
        
        _contentContainer.backgroundColor = UIColor.lightGrayColor()
        _contentContainer.layer.cornerRadius = 5
        _contentContainer.layer.masksToBounds = true
        self.contentView.addSubview(_contentContainer)
        
        _thumbView = ImageLoader(frame: CGRectMake(0, 0, _cellWidth - ContentEdgeInsets.left * 0.5 - ContentEdgeInsets.right * 0.5, CellHeight))
        //_thumbView.
        _contentContainer.addSubview(_thumbView!)

        
        _likesLabel.frame = CGRectMake(ContentEdgeInsets.left, 20, _cellWidth - ContentEdgeInsets.left - ContentEdgeInsets.right - 20, 20)
        _likesLabel.font = UIFont.systemFontOfSize(16)
        _likesLabel.textColor = UIColor.whiteColor()
        _likesLabel.shadowColor = UIColor.blackColor()
        _likesLabel.shadowOffset = CGSizeMake(1, 1)
        _likesLabel.textAlignment = .Right
        _contentContainer.addSubview(_likesLabel)
        
        var shape:UIView = UIView()
        shape.userInteractionEnabled = false
        shape.frame = CGRectMake(0, 100, _thumbView!.width, 50)
        shape.backgroundColor = UIColor(white: 0, alpha: 0.6)
        _contentContainer.addSubview(shape)
        
        _nameLabel.frame = CGRectMake(ContentEdgeInsets.left, 105, _cellWidth - ContentEdgeInsets.left - ContentEdgeInsets.right, 20)
        _nameLabel.font = UIFont.systemFontOfSize(16)
        _nameLabel.textColor = UIColor.whiteColor()
        _nameLabel.shadowColor = UIColor.blackColor()
        _nameLabel.shadowOffset = CGSizeMake(1, 1)
        _nameLabel.textAlignment = .Left
        _contentContainer.addSubview(_nameLabel)
        
        _englishNameLabel.frame = CGRectMake(ContentEdgeInsets.left, 125, _nameLabel.width, 20)
        _englishNameLabel.font = UIFont.systemFontOfSize(16)
        _englishNameLabel.textColor = UIColor.whiteColor()
        _englishNameLabel.shadowColor = UIColor.blackColor()
        _englishNameLabel.shadowOffset = CGSizeMake(1, 1)
        _englishNameLabel.textAlignment = .Left
        _contentContainer.addSubview(_englishNameLabel)
        
    }
    
    override func prepareForReuse()
    {
        super.prepareForReuse()
        _change = true
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        if place != nil && _change
        {
            _contentContainer.frame = CGRectMake(ContentEdgeInsets.left * 0.5, ContentEdgeInsets.top * 0.5, _cellWidth - ContentEdgeInsets.left * 0.5 - ContentEdgeInsets.right * 0.5, CellHeight)
            _likesLabel.text = place!.likes == nil ? "" : String(place!.likes!)
            _nameLabel.text = place!.name ?? ""
            _englishNameLabel.text = place!.englishName ?? ""
            _thumbView!.image = nil
            if place!.thumbURL != nil
            {
                _thumbView!.load(place!.thumbURL!)
            }
        }
        
        
    }
    
    
    
    
}//end class