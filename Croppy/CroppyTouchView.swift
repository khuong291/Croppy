//
//  CroppyTouchView.swift
//  Croppy
//
//  Created by KhuongPham on 2/22/18.
//  Copyright © 2018 KhuongPham. All rights reserved.
//

class RSKTouchView: UIView {
    weak var receiver: UIView?
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if self.point(inside: point, with: event) {
            return receiver
        }
        return nil
    }
}
