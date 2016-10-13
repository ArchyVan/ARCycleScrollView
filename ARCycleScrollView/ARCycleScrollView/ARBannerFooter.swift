
//
//  ARBannerFooter.swift
//  ARCycleScrollView
//
//  Created by Objective-C on 2016/10/13.
//  Copyright © 2016年 Archy Van. All rights reserved.
//

import Foundation
import UIKit

enum ARBannerFooterState: Int {
    case normal
    case trigger
}

class ARBannerFooter: UICollectionReusableView {
    var state : ARBannerFooterState! {
        didSet {
            if self.state == .normal {
                self.label.text = self.normalTiltle
                UIView.animate(withDuration: 0.3, animations: {
                    self.arrowView.transform = CGAffineTransform.init(rotationAngle: 0)
                })
            } else {
                self.label.text = self.triggerTitle
                UIView.animate(withDuration: 0.3, animations: {
                    self.arrowView.transform = CGAffineTransform.init(rotationAngle: CGFloat(M_PI))
                })
            }

        }
    }
    lazy var arrowView : UIImageView = {
        let imageView = UIImageView.init()
        return imageView
    }()
    var label : UILabel = {
        let label = UILabel.init()
        return label
    }()
    var normalTiltle : String? = "拖动查看详情"
    var triggerTitle : String? = "释放查看详情"
    var arrowImageName : String? = "test"
    let ARArrowSide = 15.0
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(arrowView)
        self.addSubview(label)
        self.arrowView.image = UIImage.init(named: arrowImageName!)
        self.state = .normal
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let arrowX = (self.bounds.size.width / 2.0) - 15.0 - 2.0
        let arrowY = (self.bounds.size.height / 2.0) - 15.0 / 2.0
        let arrowW : CGFloat = 15.0
        let arrowH : CGFloat = 15.0
        self.arrowView.frame = CGRect.init(x: arrowX, y: arrowY, width: arrowW, height: arrowH)
        
        let labelX = self.bounds.size.width / 2.0 + 2.0
        let labelY : CGFloat = 0
        let labelW : CGFloat = 15
        let labelH : CGFloat = self.bounds.size.height
        self.label.frame = CGRect.init(x: labelX, y: labelY, width: labelW, height: labelH)
        
    }
}
