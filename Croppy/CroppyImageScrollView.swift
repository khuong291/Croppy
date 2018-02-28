//
//  CroppyImageScrollView.swift
//  Croppy
//
//  Created by KhuongPham on 2/26/18.
//  Copyright © 2018 KhuongPham. All rights reserved.
//

open class CroppyImageScrollView: UIScrollView {
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
    
    open func setFrame(_ frame: CGRect) {
        let sizeChanging = frame.size.equalTo(self.frame.size)
        
        if sizeChanging {
            prepareToResize()
        }
        
        self.frame = frame
        
        if sizeChanging {
            recoverFromResizing()
        }
        
        centerZoomView()
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
    
    // MARK: Center zoomView within scrollView
    open func centerZoomView() {
        // center zoomView as it becomes smaller than the size of the screen
        
        // we need to use contentInset instead of contentOffset for better positioning when zoomView fills the screen
        if isAspectFill {
            var top: CGFloat = 0.0
            var left: CGFloat = 0.0
            
            // center vertically
            if contentSize.height < bounds.height {
                top = (bounds.height - contentSize.height) * 0.5
            }
            
            // center horizontally
            if contentSize.width < bounds.width {
                left = (bounds.width - contentSize.width) * 0.5
            }
            
            contentInset = UIEdgeInsetsMake(top, left, top, left)
        } else if let zoomView = zoomView {
            var frameToCenter = zoomView.frame
            
            // center horizontally
            if frameToCenter.width < bounds.width {
                frameToCenter.origin.x = (bounds.width - frameToCenter.width) * 0.5
            } else {
                frameToCenter.origin.x = 0
            }
            
            // center vertically
            if frameToCenter.height < bounds.height {
                frameToCenter.origin.y = (bounds.height - frameToCenter.height) * 0.5
            } else {
                frameToCenter.origin.y = 0
            }
        }
    }
    
    // MARK: Configure scrollView to display new image
    open func displayImage(_ image: UIImage) {
        // clear view for the previous image
        zoomView?.removeFromSuperview()
        zoomView = nil
        
        // reset our zoomScale to 1.0 before doing any further calculations
        zoomScale = 1.0
        
        // make views to display the new image
        zoomView = UIImageView(image: image)
        addSubview(zoomView!)
        configureForImageSize(image.size)
    }
    
    open func configureForImageSize(_ imageSize: CGSize) {
        self.imageSize = imageSize
        contentSize = imageSize
        setMaxMinZoomScalesForCurrentBounds()
        setInitialZoomScale()
        setInitialContentOffset()
        contentInset = UIEdgeInsets.zero
    }
    
    open func setInitialZoomScale() {
        let boundsSize = bounds.size
        let xScale = boundsSize.width / imageSize.width // the scale needed to perfectly fit the image width-wise
        let yScale = boundsSize.height / imageSize.height // the scale needed to perfectly fit the image height-wise
        let scale = max(xScale, yScale)
        zoomScale = scale
    }
    
    open func setInitialContentOffset() {
        guard let zoomView = zoomView else {
            return
        }
        let boundsSize = bounds.size
        let frameToCenter = zoomView.frame
        
        var contentOffset: CGPoint = .zero
        
        if frameToCenter.width > boundsSize.width {
            contentOffset.x = (frameToCenter.width - boundsSize.width) * 0.5
        } else {
            contentOffset.x = 0
        }
        
        if frameToCenter.height > boundsSize.height {
            contentOffset.y = (frameToCenter.height - boundsSize.height) * 0.5
        } else {
            contentOffset.y = 0
        }
        
        setContentOffset(contentOffset, animated: false)
    }
    
    // MARK: Methods called during rotation to preserve the zoomScale and the visible portion of the image
    open func prepareToResize() {
        guard let zoomView = zoomView else {
            return
        }
        
        let boundsCenter = CGPoint(x: bounds.midX, y: bounds.midY)
        pointToCenterAfterResize = convert(boundsCenter, to: zoomView)
        
        scaleToRestoreAfterResize = zoomScale
        
        // If we're at the minimum zoom scale, preserve that by returning 0, which will be converted to the minimum
        // allowable scale when the scale is restored.
        if scaleToRestoreAfterResize <= minimumZoomScale + CGFloat(Float.ulpOfOne) {
            scaleToRestoreAfterResize = 0
        }
    }
    
    open func recoverFromResizing() {
        guard let zoomView = zoomView else {
            return
        }
        
        setMaxMinZoomScalesForCurrentBounds()
        
        // Step 1: restore zoom scale, first making sure it is within the allowable range.
        let maxZoomScale = max(minimumZoomScale, scaleToRestoreAfterResize)
        zoomScale = min(maximumZoomScale, maxZoomScale)
        
        // Step 2: restore center point, first making sure it is within the allowable range.
        
        // 2a: convert our desired center point back to our own coordinate space
        let boundsCenter = convert(pointToCenterAfterResize, to: zoomView)
        
        // 2b: calculate the content offset that would yield that center point
        var offset = CGPoint(x: boundsCenter.x - bounds.width / 2, y: boundsCenter.y - bounds.height / 2)
        
        // 2c: restore offset, adjusted to be within the allowable range
        let maxOffset = maximumContentOffset()
        let minOffset = minimumContentOffset()
        
        var realMaxOffset = min(maxOffset.x, offset.x)
        offset.x = max(minOffset.x, realMaxOffset)
        
        realMaxOffset = min(maxOffset.y, offset.y)
        offset.y = max(minOffset.y, realMaxOffset)
        
        contentOffset = offset
    }
    
    open func maximumContentOffset() -> CGPoint {
        return CGPoint(x: contentSize.width - bounds.width, y: contentSize.height - bounds.height)
    }
    
    open func minimumContentOffset() -> CGPoint {
        return CGPoint.zero
    }
}

extension CroppyImageScrollView: UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return zoomView
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerZoomView()
    }
}
