//
//  ImageRounding.swift
//  SomaKit
//
//  Created by Anton on 28.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import AlamofireImage

public enum ImageRoundingMode {
    case cicrular
    case corners(radius: CGFloat)
    
    public var imagePluginKey: String {
        switch self {
        case .cicrular:
            return "Circular"
        case .corners(let radius):
            return "Corners" + String(describing: radius)
        }
    }
}

open class ImageRounding: ImagePluginType {
    fileprivate let mode: ImageRoundingMode
    
    open var imagePluginKey: String {
        return mode.imagePluginKey
    }
    
    open func transform(image: UIImage) throws -> UIImage {
        switch mode {
        case .cicrular:
            return image.af_imageRoundedIntoCircle()
        case .corners(let radius):
            return image.af_imageRounded(withCornerRadius: radius)
        }
    }
    
    public init(mode: ImageRoundingMode = .cicrular) {
        self.mode = mode;
    }
}
