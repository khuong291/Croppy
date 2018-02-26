//
//  CroppyImageScrollView.swift
//  Croppy
//
//  Created by KhuongPham on 2/26/18.
//  Copyright © 2018 KhuongPham. All rights reserved.
//

open class CroppyImageScrollView: UIScrollView, UIScrollViewDelegate {
    open var zoomView: UIImageView?
    open var isAspectFill = false
    
    private var imageSize: CGSize = .zero
    private var pointToCenterAfterResize: CGPoint = .zero
    private var scaleToRestoreAfterResize: CGFloat = 0.0
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        isAspectFill = false
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        bouncesZoom = true
        scrollsToTop = false
        decelerationRate = UIScrollViewDecelerationRateFast
        delegate = self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        
        centerZoomView()
    }
    
    open func setAspectFill(_ isAspectFill: Bool) {
        if self.isAspectFill != isAspectFill {
            self.isAspectFill = isAspectFill
            
            if zoomView != nil {
                setMaxMinZoomScalesForCurrentBounds()
                
                if zoomScale < minimumZoomScale {
                    zoomScale = minimumZoomScale
                }
            }
        }
    }
    
    open func setMaxMinZoomScalesForCurrentBounds() {
        let boundsSize = bounds.size
        
        // calculate min/max zoomscale
        let xScale = boundsSize.width / imageSize.width // the scale needed to perfectly fit the image width-wise
        let yScale = boundsSize.height / imageSize.height // the scale needed to perfectly fit the image height-wise
        
        var minScale: CGFloat
        
        if !isAspectFill {
            minScale = min(xScale, yScale) // use minimum of these to allow the image to become fully visible
        } else {
            minScale = max(xScale, yScale) // use maximum of these to allow the image to fill the screen
        }
        
        var maxScale = max(xScale, yScale)
        
        // Image must fit/fill the screen, even if its size is smaller.
        let xImageScale = maxScale * imageSize.width / boundsSize.width
        let yImageScale = maxScale * imageSize.height / boundsSize.height
        
        var maxImageScale = max(xImageScale, yImageScale)
        
        maxImageScale = max(minScale, maxImageScale)
        maxScale = max(maxScale, maxImageScale)
        
        // don't let minScale exceed maxScale. (If the image is smaller than the screen, we don't want to force it to be zoomed.)
        if minScale > maxScale {
            minScale = maxScale
        }
        
        maximumZoomScale = maxScale
        minimumZoomScale = minScale
    }
    
    open func centerZoomView() {
        // center zoomView as it becomes smaller than the size of the screen
        
        // we need to use contentInset instead of contentOffset for better positioning when zoomView fills the screen
        if isAspectFill {
            var top: CGFloat = 0.0
            var left: CGFloat = 0.0
            
            // center vertically
            if contentSize.height < bounds.height {
                top = bounds.height - contentSize.height * 0.5
            }
            
            // center horizontally
            if contentSize.width < bounds.width {
                left = bounds.width - contentSize.width * 0.5
            }
            
            contentInset = UIEdgeInsetsMake(top, left, top, left)
        } else if let zoomView = zoomView {
            var frameToCenter = zoomView.frame
            
            // center horizontally
            if frameToCenter.width < bounds.width {
                frameToCenter.origin.x = bounds.width - frameToCenter.width * 0.5
            } else {
                frameToCenter.origin.x = 0
            }
            
            // center vertically
            if frameToCenter.height < bounds.height {
                frameToCenter.origin.y = bounds.height - frameToCenter.height * 0.5
            } else {
                frameToCenter.origin.y = 0
            }
        }
    }
    
}
