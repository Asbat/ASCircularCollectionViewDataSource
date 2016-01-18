//
//  ASCircularCollectionViewDataSource.swift
//  ASCircularCollectionView
//
//  Created by Alexey Stoyanov on 12/24/15.
//  Copyright © 2015 Alexey Stoyanov. All rights reserved.
//

import UIKit

@objc
public protocol ASCircularCollectionViewDelegate : NSObjectProtocol
{
    func circularCollectionView(circularCollectionView: UICollectionView, customizeWithdata data: AnyObject?, item: Int) -> UICollectionViewCell
    
    optional func circularCollectionView(circularCollectionView: UICollectionView, didSelectItem item: Int)
}

public class ASCircularCollectionViewDataSource: NSObject, UICollectionViewDelegate, UICollectionViewDataSource
{
    
    // MARK: Constants
    
    private static let MirrorItemsCount         : Int = 2
    
    // MARK: Static Vars
    
    private static var LastContentOffset        : CGFloat = CGFloat(FLT_MIN)
    
    // MARK: Properties
    private var itemsCount                      : Int = 0
    private var items                           : [AnyObject]? = nil
    private var collectionView                  : UICollectionView? = nil
    
    var delegate                                : ASCircularCollectionViewDelegate? = nil
    
    // MARK: - Methods
    
    override public func awakeFromNib()
    {
        
    }
    
    // MARK: - UICollectionViewDataSource
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.itemsCount
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        return (self.delegate?.circularCollectionView(collectionView, customizeWithdata: self.items?[indexPath.row], item: indexPath.row))!
    }
    
    // MARK: - UICollectionViewDelegate
    
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        self.delegate?.circularCollectionView?(collectionView, didSelectItem: indexPath.row)
    }
    
    // MARK: - UIScrollViewDelegate
    
    public func scrollViewDidScroll(scrollView: UIScrollView)
    {
        let insetFrame                                      = UIEdgeInsetsInsetRect(scrollView.frame, scrollView.contentInset)
        
        let currentOffsetX                                  = scrollView.contentInset.left + scrollView.contentOffset.x
        let currentOffsetY                                  = scrollView.contentOffset.y
        
        let pageWidth                                       = insetFrame.size.width
        let offset                                          = scrollView.contentInset.left + pageWidth * CGFloat(self.itemsCount - 2)
        
        if ((currentOffsetX < pageWidth) &&
            (ASCircularCollectionViewDataSource.LastContentOffset > currentOffsetX))
        {
            // the first page(showing the last item) is visible and user's finger is still scrolling to the right
            ASCircularCollectionViewDataSource.LastContentOffset  = currentOffsetX + offset - 2*scrollView.contentInset.left;
            scrollView.contentOffset                        = CGPointMake(ASCircularCollectionViewDataSource.LastContentOffset, currentOffsetY);
        }
            
        else if ((currentOffsetX > offset) &&
            (ASCircularCollectionViewDataSource.LastContentOffset < currentOffsetX))
        {
            // the last page (showing the first item) is visible and the user's finger is still scrolling to the left
            ASCircularCollectionViewDataSource.LastContentOffset  = currentOffsetX - offset;
            scrollView.contentOffset                        = CGPointMake(ASCircularCollectionViewDataSource.LastContentOffset, currentOffsetY);
        }
        else
        {
            ASCircularCollectionViewDataSource.LastContentOffset  = currentOffsetX;
        }
    }
    
    //    public func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
    //    {
    //        // Get the size of the page, adjusting for the content insets.
    //        let insetFrame = UIEdgeInsetsInsetRect( scrollView.frame, scrollView.contentInset );
    //
    //        // Determine the page index to fall on based on scroll position.
    //        var pageIndex = (scrollView.contentOffset.x + scrollView.contentInset.left) / insetFrame.size.width;
    //
    //        if (velocity.x > 0)
    //        {
    //            pageIndex = ceil( pageIndex );
    //        }
    //        else if (velocity.x == 0)
    //        {
    //            pageIndex = round( pageIndex );
    //        }
    //        else
    //        {
    //            pageIndex = floor( pageIndex );
    //        }
    //
    //        pageIndex = pageIndex < 0.0 ? 0.0 : pageIndex;
    //        var newOffset = (pageIndex * insetFrame.size.width);
    //
    //        if( newOffset > scrollView.contentSize.width - insetFrame.size.width )
    //        {
    //            newOffset = scrollView.contentSize.width - insetFrame.size.width;
    //        }
    //
    //        // Set our target content offset.
    //        //    targetContentOffset->x = newOffset - scrollView.contentInset.left;
    //
    //        scrollView.setContentOffset(CGPointMake(newOffset - scrollView.contentInset.left, 0.0), animated: true)
    //    }
    
    // MARK: - Public Methods
    
    public func attachToCollectionView(cv: UICollectionView, items: [AnyObject])
    {
        if (items.count < 2)
        {
            return
        }
        
        self.collectionView             = cv
        
        self.itemsCount                 = items.count + ASCircularCollectionViewDataSource.MirrorItemsCount
        self.items                      = items
        
        self.items?.append(items.first!)
        self.items?.insert(items.last!, atIndex: 0)
    }
    
    public func itemSize(size: CGSize)
    {
        if let lCollectionView = self.collectionView
        {
            (lCollectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize = size
            
            lCollectionView.delegate                     = self
            lCollectionView.dataSource                   = self
            
            self.collectionView?.performBatchUpdates({ () -> Void in
                self.collectionView?.collectionViewLayout.invalidateLayout()
                }, completion: { (Bool) -> Void in
                    self.collectionView?.reloadData()
                    self.collectionView?.scrollToItemAtIndexPath(NSIndexPath(forItem: 1, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: false)
            })
        }
    }
    
}
