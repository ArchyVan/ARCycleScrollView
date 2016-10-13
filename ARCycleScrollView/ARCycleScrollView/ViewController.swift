//
//  ViewController.swift
//  ARCycleScrollView
//
//  Created by Objective-C on 2016/10/13.
//  Copyright © 2016年 Archy Van. All rights reserved.
//

import UIKit

let ScreenWidth = UIScreen.main.bounds.size.width
let ScreenHeight = UIScreen.main.bounds.size.height
class ViewController: UIViewController ,ARBannerViewDataSource, ARBannerViewDelegate{

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    
        let bannerView = ARBannerView.init(frame: CGRect.init(x: 0, y: 20, width: ScreenWidth, height: 100))
        bannerView.dataSource = self
        bannerView.delegate = self
        bannerView.showFooter = true
        self.view.addSubview(bannerView)
        
    }
    
    func banner(_ banner: ARBannerView, itemForIndexAt index: NSInteger) -> UIView {
        let itemView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: ScreenWidth, height: 100))
        if index % 2  == 1 {
            itemView.backgroundColor = UIColor.red
        } else {
            itemView.backgroundColor = UIColor.blue
        }
        return itemView
    }
    
    func numberOfItems(in banner: ARBannerView) -> NSInteger {
        return 6
    }
    
    func banner(_ banner: ARBannerView, titleForFooterState state: NSInteger) -> NSString {
        return "Test"
    }
    
    func footerDidTrigger(in banner: ARBannerView) {
        print("123123")
    }
    
}

