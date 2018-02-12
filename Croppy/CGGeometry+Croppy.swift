//
//  CGGeometry+Croppy.swift
//  Croppy
//
//  Created by KhuongPham on 2/12/18.
//  Copyright © 2018 KhuongPham. All rights reserved.
//

import CoreGraphics

let croppyPointNull: CGPoint = CGPoint(x: CGFloat(FP_INFINITE), y: CGFloat(FP_INFINITE))

func croppyRectCenterPoint(rect: CGRect) -> CGPoint {
    return CGPoint(x: rect.minX + rect.width / 2, y: rect.minY + rect.height / 2)
}

func croppyRectScaleAroundPoint(rect: CGRect, point: CGPoint, sx: CGFloat, sy: CGFloat) -> CGRect {
    var rect = rect
    var translationTransform = CGAffineTransform(translationX: -point.x, y: -point.y)
    rect = rect.applying(translationTransform)
    let scaleTransform = CGAffineTransform(scaleX: sx, y: sy)
    rect = rect.applying(scaleTransform)
    translationTransform = CGAffineTransform(translationX: point.x, y: point.y)
    rect = rect.applying(translationTransform)
    return rect
}

func croppyPointIsNull(point: CGPoint) -> Bool {
    return point.equalTo(croppyPointNull)
}
