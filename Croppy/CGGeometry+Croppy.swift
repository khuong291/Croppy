//
//  CGGeometry+Croppy.swift
//  Croppy
//
//  Created by KhuongPham on 2/12/18.
//  Copyright © 2018 KhuongPham. All rights reserved.
//

import CoreGraphics

public struct CroppyLineSegment {
    var start: CGPoint
    var end: CGPoint
}

public let croppyPointNull: CGPoint = CGPoint(x: CGFloat(FP_INFINITE), y: CGFloat(FP_INFINITE))

public func croppyRectCenterPoint(rect: CGRect) -> CGPoint {
    return CGPoint(x: rect.minX + rect.width / 2, y: rect.minY + rect.height / 2)
}

public func croppyRectScaleAroundPoint(rect: CGRect, point: CGPoint, sx: CGFloat, sy: CGFloat) -> CGRect {
    var rect = rect
    var translationTransform = CGAffineTransform(translationX: -point.x, y: -point.y)
    rect = rect.applying(translationTransform)
    let scaleTransform = CGAffineTransform(scaleX: sx, y: sy)
    rect = rect.applying(scaleTransform)
    translationTransform = CGAffineTransform(translationX: point.x, y: point.y)
    rect = rect.applying(translationTransform)
    return rect
}

public func croppyPointIsNull(point: CGPoint) -> Bool {
    return point.equalTo(croppyPointNull)
}

public func croppyPointRotateAroundPoint(point: CGPoint, pivot: CGPoint, angle: CGFloat) -> CGPoint {
    var point = point
    var translationTransform = CGAffineTransform(translationX: -pivot.x, y: -pivot.y)
    point = point.applying(translationTransform)
    let rotationTransform = CGAffineTransform(rotationAngle: angle)
    point = point.applying(rotationTransform)
    translationTransform = CGAffineTransform(translationX: pivot.x, y: pivot.y)
    point = point.applying(translationTransform)
    return point
}

public func croppyPointDistance(p1: CGPoint, p2: CGPoint) -> CGFloat {
    let dx = p1.x - p2.x
    let dy = p1.y - p2.y
    return sqrt(pow(dx, 2) + pow(dy, 2))
}

public func croppyLineSegmentMake(start: CGPoint, end: CGPoint) -> CroppyLineSegment {
    return CroppyLineSegment(start: start, end: end)
}

public func croppyLineSegmentRotateAroundPoint(line: CroppyLineSegment, pivot: CGPoint, angle: CGFloat) -> CroppyLineSegment {
    return croppyLineSegmentMake(start: croppyPointRotateAroundPoint(point: line.start, pivot: pivot, angle: angle),
                                 end: croppyPointRotateAroundPoint(point: line.end, pivot: pivot, angle: angle))
}
