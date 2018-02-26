//
//  CroppyTouchView.swift
//  Croppy
//
//  Created by KhuongPham on 2/22/18.
//  Copyright © 2018 KhuongPham. All rights reserved.
//

open class CroppyTouchView: UIView {
    open weak var receiver: UIView?
    
    override open func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if self.point(inside: point, with: event) {
            return receiver
        }
        return nil
    }
}
