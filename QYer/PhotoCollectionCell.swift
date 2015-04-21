//
//  PhotoCollectionCell.swift
//  QYer
//
//  Created by linhan on 15-4-18.
//  Copyright (c) 2015年 linhan. All rights reserved.
//

import Foundation
import UIKit
class PhotoCollectionCell: UICollectionViewCell
{
    private var _data:Photo?
    var data:Photo?
        {
        get
        {
            return _data
        }
        set
        {
            _data = newValue
            if _inited && _change
            {
                layoutSubviews()
            }
        }
    }
    
    private var _change:Bool = true
    
    private var _inited:Bool = false
    
    var thumbImageView:ImageLoader = ImageLoader(frame: CGRectZero)
    
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
        thumbImageView.frame = CGRectMake(0, 0, self.width, self.height)
        thumbImageView.completeCallback = imageLoadedCompleteCallback
        self.contentView.addSubview(thumbImageView)
        
        
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
        
        if data != nil && _change
        {
            _change = false
            thumbImageView.image = nil
            if data!.thumbURL != nil
            {
                thumbImageView.load(data!.thumbURL!)
            }
            
        }
    }
    
    //缩略图加载完成
    private func imageLoadedCompleteCallback(imageView:UIImageView, readFromCache:Bool)
    {
        if !readFromCache
        {
            imageView.alpha = 0
            UIView.animateWithDuration(0.3, animations: {
                imageView.alpha = 1
            })
        }
    }
    
    
}