
//
//  ARBannerView.swift
//  ARCycleScrollView
//
//  Created by Objective-C on 2016/10/13.
//  Copyright © 2016年 Archy Van. All rights reserved.
//

import Foundation
import UIKit

@objc
protocol ARBannerViewDelegate {
    @objc optional func banner(_ banner : ARBannerView, didSelectItemAt index: NSInteger )
    @objc optional func footerDidTrigger(in banner : ARBannerView)
}

protocol ARBannerViewDataSource {
    func numberOfItems(in banner : ARBannerView) -> NSInteger
    func banner(_ banner : ARBannerView, itemForIndexAt index: NSInteger) -> UIView
    func banner(_ banner : ARBannerView, titleForFooterState state:NSInteger) -> NSString
}

class ARBannerView: UICollectionReusableView, UICollectionViewDelegate, UICollectionViewDataSource {
    public var shouldLoop : Bool = true {
        didSet {
            if showFooter {
                self.shouldLoop = false
            }
            if itemCount == 1 {
                self.shouldLoop = false
            }
            reloadData()
            fixDefaultPosition()
        }
    }
    public var showFooter : Bool = false {
        didSet {
            shouldLoop = false
            reloadData()
        }
    }
    var autoScroll : Bool = true {
        didSet {
            if self.itemCount < 2 {
                self.autoScroll = false
            }
            if self.autoScroll {
                startTimer()
            } else {
                stopTimer()
            }
        }
    }
    var scrollInterval : TimeInterval = 3 {
        didSet{
            if self.scrollInterval == 0 {
                self.scrollInterval = 3
            }
            startTimer()
        }
    }
    var delegate : ARBannerViewDelegate?
    var dataSource : ARBannerViewDataSource?
    lazy private var collectionView : UICollectionView = {
        let collection = UICollectionView.init(frame: self.bounds, collectionViewLayout: self.flowLayout)
        collection.isPagingEnabled = true
        
        collection.alwaysBounceHorizontal = true
        collection.showsHorizontalScrollIndicator = false
        collection.scrollsToTop = false
        collection.backgroundColor = UIColor.groupTableViewBackground
        collection.delegate = self
        collection.dataSource = self
        collection.register(ARBannerCell.classForCoder(), forCellWithReuseIdentifier: "banner_cell")
        collection.register(ARBannerFooter.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "banner_footer")
        collection.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: -64)
        return collection
    }()
    
    lazy private var flowLayout : UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout.init()
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.scrollDirection = .horizontal
        flowLayout.sectionInset = UIEdgeInsets.zero
        return flowLayout
    }()
    private var footer : ARBannerFooter?
    private var itemCount : NSInteger  {
        get {
            return (dataSource?.numberOfItems(in: self))!
        }
    }
    private var timer : Timer?
    
    public func reloadData() {
        if self.itemCount == 0 {
            return
        }
        self.collectionView.reloadData()
        startTimer()
    }
    
    public func startTimer() {
        if !self.autoScroll {
            return
        }
        
        stopTimer()
        self.timer = Timer.scheduledTimer(timeInterval: self.scrollInterval, target: self, selector: #selector(autoScrollToNextItem), userInfo: nil, repeats: true)
        RunLoop.current.add(self.timer!, forMode: .commonModes)
    }
    
    @objc private func autoScrollToNextItem() {
        if self.itemCount == 0 || self.itemCount == 1 || !self.autoScroll {
            return
        }
        
        let currentIndexPath = self.collectionView.indexPathsForVisibleItems.first
        let currentItem = currentIndexPath?.item
        let nextItem = currentItem! + 1
        if nextItem >= self.itemCount * 20000 {
            return
        }
        
        if self.shouldLoop {
            self.collectionView.scrollToItem(at: NSIndexPath.init(item: nextItem, section: 0) as IndexPath, at: .left, animated: true)
        } else {
            if ((currentItem! % self.itemCount) == self.itemCount - 1) {
                self.collectionView.scrollToItem(at: NSIndexPath.init(item: 0, section: 0) as IndexPath, at: .left, animated: true)
            } else {
                self.collectionView.scrollToItem(at: NSIndexPath.init(item: nextItem, section: 0) as IndexPath, at: .left, animated: true)
            }
        }
    }
    
    public func stopTimer() {
        self.timer?.invalidate()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateSubviewsFrame()
    }
    
    private func updateSubviewsFrame() {
        self.flowLayout.itemSize = self.bounds.size
        self.flowLayout.footerReferenceSize = CGSize.init(width: 64, height: self.frame.size.height)
        self.collectionView.frame = self.bounds
    }
    
    private func commonInit() {
        self.addSubview(self.collectionView)
    }
    
    private func fixDefaultPosition() {
        if self.itemCount == 0 {
            return
        }
        
        if self.shouldLoop {
            DispatchQueue.main.async {
                self.collectionView.scrollToItem(at: NSIndexPath.init(item: (self.itemCount * 10000), section: 0) as IndexPath, at: .left, animated: false)
            }
        } else {
            DispatchQueue.main.async {
                self.collectionView.scrollToItem(at: NSIndexPath.init(item: 0, section: 0) as IndexPath, at: .left, animated: false)
                
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.shouldLoop {
            return self.itemCount * 20000
        } else {
            return self.itemCount
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : ARBannerCell = collectionView.dequeueReusableCell(withReuseIdentifier: "banner_cell", for: indexPath) as! ARBannerCell
        
        if let itemView = self.dataSource?.banner(self, itemForIndexAt: indexPath.item % self.itemCount) {
            cell.contentView.addSubview(itemView)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var footer: UICollectionReusableView?
        if kind == UICollectionElementKindSectionFooter {
            footer = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "banner_footer", for: indexPath)
            self.footer = footer as? ARBannerFooter
            let normalTitle = self.dataSource?.banner(self, titleForFooterState: 0)
            let triggerTitle = self.dataSource?.banner(self, titleForFooterState: 1)
            self.footer?.normalTiltle = normalTitle as String!
            self.footer?.triggerTitle = triggerTitle as String!
        }
        
        if self.showFooter {
            self.footer?.isHidden = false
        } else {
            self.footer?.isHidden = true
        }
        
        return self.footer!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.banner!(self, didSelectItemAt: indexPath.item)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        stopTimer()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        startTimer()
    }
    
    var lastOffset : CGFloat = 0
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !self.showFooter {
            return
        }
        
        let footerDisplayOffset = scrollView.contentOffset.x - CGFloat(self.frame.size.width * CGFloat(self.itemCount - 1))
        if footerDisplayOffset > 0 {
            if footerDisplayOffset > 64 {
                if lastOffset > 0 {
                    return
                }
                self.footer?.state = .trigger
            } else {
                if lastOffset < 0 {
                    return
                }
                self.footer?.state = .normal
            }
            lastOffset = footerDisplayOffset - 64
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !self.showFooter {
            return
        }
        
        let footerDisplayOffset = scrollView.contentOffset.x - (self.frame.size.width * CGFloat(self.itemCount - 1));
        
        // 通知footer代理
        if (footerDisplayOffset > 64) {
            delegate?.footerDidTrigger!(in: self)
        }
    }
}
