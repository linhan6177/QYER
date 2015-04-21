//
//  RebateCell.swift
//  QYer
//
//  Created by linhan on 15-4-11.
//  Copyright (c) 2015年 linhan. All rights reserved.
//

import Foundation
import UIKit
class RebateCell: UICollectionViewCell
{
    private var _item:RebateItem?
    var item:RebateItem?
    {
        get
        {
            return _item
        }
        set
        {
            _item = newValue
            if _inited && _change
            {
                layoutSubviews()
            }
        }
    }
    
    private var _change:Bool = true
    
    private var _inited:Bool = false
    
    private var _captionLabel:UILabel = UILabel()
    private var _endLabel:UILabel = UILabel()
    private var _priceLabel:UILabel = UILabel()
    private var _discountLabel:UILabel = UILabel()
    private var _coverImageView:ImageLoader = ImageLoader(frame: CGRectZero)
    private var _backGroundView:UIView = UIView()
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup()
    {
        
        _backGroundView.frame = CGRectMake(0, 0, self.width - 5, self.height)
        _backGroundView.layer.borderColor = UIColor(white: 220 / 255, alpha: 1).CGColor
        _backGroundView.layer.borderWidth = 0.5
        _backGroundView.backgroundColor = UIColor.whiteColor()
        self.contentView.addSubview(_backGroundView)
        
        _coverImageView.frame = CGRectMake(0, 0, _backGroundView.width, 70)
        _coverImageView.completeCallback = imageLoadedCompleteCallback
        self.contentView.addSubview(_coverImageView)
        
        var pinkImage:UIImageView = UIImageView(image:UIImage(named:"pinkLabel"))
        pinkImage.frame = CGRectMake(self.width - pinkImage.width, _coverImageView.height - pinkImage.height - 5, pinkImage.width, pinkImage.height)
        self.contentView.addSubview(pinkImage)
        
        _priceLabel.textColor = UIColor.whiteColor()
        _priceLabel.textAlignment = .Center
        _priceLabel.font = UIFont.systemFontOfSize(14)
        _priceLabel.frame = pinkImage.frame
        self.contentView.addSubview(_priceLabel)
        
        var captionLabelX:CGFloat = 5
        _captionLabel.textColor = UIColor.darkGrayColor()
        _captionLabel.font = UIFont.systemFontOfSize(14)
        _captionLabel.numberOfLines = 2
        _captionLabel.frame = CGRectMake(captionLabelX, _coverImageView.bottom + 10, _backGroundView.width - captionLabelX * 2, 40)
        self.contentView.addSubview(_captionLabel)
        
        
        
        _discountLabel.textColor = UIColor.redColor()
        _discountLabel.font = UIFont.systemFontOfSize(12)
        _discountLabel.text = "950折"
        _discountLabel.sizeToFit()
        _discountLabel.textAlignment = .Right
        _discountLabel.frame = CGRectMake(_backGroundView.width - _discountLabel.width - 5, self.height - 25, _discountLabel.width, _discountLabel.height)
        self.contentView.addSubview(_discountLabel)
        
        _endLabel.frame = CGRectMake(captionLabelX, _discountLabel.y, _backGroundView.width - _discountLabel.width, _discountLabel.height)
        _endLabel.textColor = UIColor.lightGrayColor()
        _endLabel.font = UIFont.systemFontOfSize(12)
        self.contentView.addSubview(_endLabel)
        
        
        _inited = true
    }
    
    override func prepareForReuse()
    {
        super.prepareForReuse()
        _change = true
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        if item != nil && _change
        {
            _change = false
            _captionLabel.text = item!.caption ?? ""
            _priceLabel.text = item!.price == nil ? "" : item!.price! + "元起"
            _endLabel.text = item!.endDate ?? ""
            _discountLabel.text = item!.discount ?? ""
            _coverImageView.image = nil
            if item!.coverURL != nil
            {
                _coverImageView.load(item!.coverURL!)
            }
            
        }
    }
    
    //缩略图加载完成
    private func imageLoadedCompleteCallback(imageView:UIImageView, readFromCache:Bool)
    {
        if !readFromCache
        {
            _coverImageView.alpha = 0
            UIView.animateWithDuration(0.3, animations: {
                self._coverImageView.alpha = 1
            })
        }
    }
    
    
    
    
}