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

public func croppyLineSegmentIntersection(ls1: CroppyLineSegment, ls2: CroppyLineSegment) -> CGPoint {
    let x1 = ls1.start.x
    let y1 = ls1.start.y
    let x2 = ls1.end.x
    let y2 = ls1.end.y
    let x3 = ls2.start.x
    let y3 = ls2.start.y
    let x4 = ls2.end.x
    let y4 = ls2.end.y
    
    let numeratorA = (x4 - x3) * (y1 - y3) - (y4 - y3) * (x1 - x3)
    let numeratorB = (x2 - x1) * (y1 - y3) - (y2 - y1) * (x1 - x3)
    let denominator = (y4 - y3) * (x2 - x1) - (x4 - x3) * (y2 - y1)
    
    // Check the coincidence
    if fabs(numeratorA) < CGFloat(Float.ulpOfOne) && fabs(numeratorB) < CGFloat(Float.ulpOfOne) && fabs(denominator) < CGFloat(Float.ulpOfOne) {
        return CGPoint(x: (x1 + x2) * 0.5, y: (y1 + y2) * 0.5)
    }
    
    // Check the parallelism.
    if fabs(denominator) < CGFloat(Float.ulpOfOne) {
        return croppyPointNull
    }
    
    // Check the intersection.
    let uA = numeratorA / denominator
    let uB = numeratorB / denominator
    
    if (uA < 0 || uA > 1 || uB < 0 || uB > 1) {
        return croppyPointNull
    }
    
    return CGPoint(x: x1 + uA * (x2 - x1), y: y1 + uA * (y2 - y1))
}
