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
    }
}
