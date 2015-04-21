//
//  AppConfig.swift
//  QYer
//
//  Created by linhan on 15-4-6.
//  Copyright (c) 2015年 linhan. All rights reserved.
//

import Foundation
import UIKit

class AppConfig: NSObject
{
    private var _navigationBarHeight:CGFloat = 44
    private var _tabBarHeight:CGFloat = 44
    class func shared()->AppConfig
    {
        struct Static {
            static var instance : AppConfig? = nil
            static var token : dispatch_once_t = 0
        }
        dispatch_once(&Static.token)
            { Static.instance = AppConfig()
                println("create AppConfig()")}
        
        return Static.instance!
    }
    
    
    
    var statusBarHeight:CGFloat
        {
            return UIApplication.sharedApplication().statusBarFrame.height
    }
    
    var navigationBarHeight:CGFloat
        {
        get
        {
            return _navigationBarHeight
        }
        set
        {
            _navigationBarHeight = newValue
        }
    }
    
    var tabBarHeight:CGFloat
        {
        get
        {
            return _tabBarHeight
        }
        set
        {
            _tabBarHeight = newValue
        }
    }
    
}