//
//  ViewController.swift
//  QYModuleTest
//
//  Created by linhan on 15-4-20.
//  Copyright (c) 2015年 linhan. All rights reserved.
//

import UIKit

extension UIViewController
{
    //导航栏上的加载进度条
    var incrementProgressView:IncrementProgressView?
        {
            if self.navigationController != nil
            {
                var barSubviews = self.navigationController!.navigationBar.subviews
                for i in 0..<barSubviews.count
                {
                    if barSubviews[i] is IncrementProgressView
                    {
                        return barSubviews[i] as? IncrementProgressView
                    }
                }
            }
            return nil
    }
    
    
    var VCBackgroundColor:UIColor
        {
            return UIColor(white: 230 / 250, alpha: 1)
    }
    
    
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

