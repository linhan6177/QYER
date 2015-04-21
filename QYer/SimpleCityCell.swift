//
//  MainBookCover.swift
//  QYer
//
//  Created by linhan on 15-4-7.
//  Copyright (c) 2015年 linhan. All rights reserved.
//

import Foundation
import UIKit
class SimpleCityCell: UIView
{
    var id:String?
    var title:String?
    private var _coverView:ImageLoader?
    private var _label:UILabel = UILabel()
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.backgroundColor = UIColor.whiteColor()
        
        var imageRect:CGRect = CGRectMake(0, 0, frame.width, frame.height)
        _coverView = ImageLoader(frame: imageRect)
        self.addSubview(_coverView!)
        
        _label.backgroundColor = UIColor(white: 0, alpha: 0.5)
        _label.frame = CGRectMake(0, frame.height - 20, frame.width, 20)
        _label.font = UIFont.systemFontOfSize(14)
        _label.textColor = UIColor.whiteColor()
        _label.textAlignment = .Center
        
        self.addSubview(_label)
        
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(coverURL:String?, title:String?)
    {
        self.title = title
        dispatch_async(dispatch_get_main_queue(), {
            
            if coverURL != nil
            {
                self._coverView!.load(coverURL!)
            }
            self._label.text = title ?? ""
        })
        
        
    }
    
    
}