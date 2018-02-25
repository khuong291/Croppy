//
//  CroppyInternalUtility.swift
//  Croppy
//
//  Created by KhuongPham on 2/25/18.
//  Copyright © 2018 KhuongPham. All rights reserved.
//

class CroppyInternalUtility {
    static func bundleForStrings() -> Bundle {
        let bundleForClass = Bundle(for: CroppyInternalUtility.self)
        
        if let stringsBundlePath = bundleForClass.path(forResource: "CroppyImageCropperStrings", ofType: "bundle") {
            return Bundle(path: stringsBundlePath) ?? bundleForClass
        }
        
        return bundleForClass
    }
}

func croppyLocalizedString(key: String, comment: String) -> String {
    return CroppyInternalUtility.bundleForStrings().localizedString(forKey: key, value: key, table: "CroppyImageCropper")
}

