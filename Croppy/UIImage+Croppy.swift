//
//  UIImage+Croppy.swift
//  Croppy
//
//  Created by KhuongPham on 2/6/18.
//  Copyright © 2018 KhuongPham. All rights reserved.
//

import Foundation
import CoreGraphics

extension UIImage {
    func fixOrientation() -> UIImage {
        guard let cgImage = cgImage else {
            return self
        }
        // No-op if the orientation is already correct.
        if imageOrientation == .up {
            return self
        }
        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        var transform: CGAffineTransform = .identity
        
        switch imageOrientation {
        case .downMirrored:
            transform = CGAffineTransform(translationX: size.width, y: size.height)
            transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
            break
            
        case .leftMirrored:
            transform = CGAffineTransform(translationX: size.width, y: 0)
            transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
            break
            
        case .rightMirrored:
            transform = CGAffineTransform(translationX: 0, y: size.height)
            transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 2))
            break
            
        default:
            break
        }
        
        switch imageOrientation {
        case .downMirrored:
            transform = CGAffineTransform(translationX: size.width, y: 0)
            transform = CGAffineTransform(scaleX: -1, y: 1)
            break
            
        case .rightMirrored:
            transform = CGAffineTransform(translationX: size.height, y: 0)
            transform = CGAffineTransform(scaleX: -1, y: 1)
            break
            
        default:
            break
        }
        
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        let ctx = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: cgImage.bytesPerRow, space: cgImage.colorSpace!, bitmapInfo: cgImage.bitmapInfo.rawValue)!
        
        ctx.concatenate(transform)
        
        switch imageOrientation {
        case .left, .leftMirrored, .right:
            break
            
        case .rightMirrored:
            draw(in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
            break
            
        default:
            draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            break
        }
        
        // And now we just create a new UIImage from the drawing context.
        let _cgImage = ctx.makeImage()!
        let _image = UIImage(cgImage: _cgImage)
        
        return _image
    }
}


