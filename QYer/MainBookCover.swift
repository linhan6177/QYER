//
//  MainBookCover.swift
//  QYer
//
//  Created by linhan on 15-4-7.
//  Copyright (c) 2015年 linhan. All rights reserved.
//

import Foundation
import UIKit
class MainBookCover: UIView
{
    var id:String?
    private var _coverView:ImageLoader?
    private var _label:UILabel = UILabel()
    
    init(frame: CGRect, coverURL:String?, title:String?)
    {
        super.init(frame: frame)
        self.backgroundColor = UIColor.whiteColor()
        
        var imageRect:CGRect = CGRectMake(0, 0, frame.width, 90)
        _coverView = ImageLoader(frame: imageRect)
        //_coverView!.layer.shouldRasterize = true
        self.addSubview(_coverView!)
        
        _label.frame = CGRectMake(10, _coverView!.height, frame.width - 20, 40)
        _label.numberOfLines = 2
        _label.font = UIFont.systemFontOfSize(14)
        _label.textColor = UIColor.darkGrayColor()
        _label.textAlignment = .Center
        
        self.addSubview(_label)
        
        update(coverURL, title:title)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(coverURL:String?, title:String?)
    {
        dispatch_async(dispatch_get_main_queue(), {
            
            if coverURL != nil
            {
                self._coverView!.load(coverURL!)
            }
            self._label.text = title ?? ""
        })
        
        
    }
    
    
}