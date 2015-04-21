//
//  POITitleView.swift
//  QYer
//
//  Created by linhan on 15-4-18.
//  Copyright (c) 2015年 linhan. All rights reserved.
//

import Foundation
import UIKit
class POITitleView: UIView {

    private var _chineseNameLabel:UILabel = UILabel()
    private var _englishNameLabel:UILabel = UILabel()
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame:CGRect)
    {
        super.init(frame:frame)
        _chineseNameLabel.frame = CGRectMake(0, 0, frame.width, 19)
        _chineseNameLabel.font = UIFont.boldSystemFontOfSize(15)
        _chineseNameLabel.textColor = UIColor.blackColor()
        _chineseNameLabel.textAlignment = .Center
        self.addSubview(_chineseNameLabel)
        
        _englishNameLabel.frame = CGRectMake(0, 18, frame.width, 16)
        _englishNameLabel.font = UIFont.boldSystemFontOfSize(12)
        _englishNameLabel.textColor = UIColor.blackColor()
        _englishNameLabel.textAlignment = .Center
        self.addSubview(_englishNameLabel)
    }
    
    override var frame:CGRect
    {
        get
        {
            return super.frame
        }
        set
        {
            println("set POITitleView frame:\(newValue)")
            super.frame = newValue
            _chineseNameLabel.width = newValue.width
            _englishNameLabel.width = newValue.width
        }
    }
    
    func update(chineseName:String?, englishName:String?)
    {
        _chineseNameLabel.text = chineseName
        _englishNameLabel.text = englishName
    }
    
    
    
}