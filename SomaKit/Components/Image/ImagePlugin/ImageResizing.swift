//
//  ImageResizing.swift
//  SomaKit
//
//  Created by Anton on 28.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import AlamofireImage

public enum ImageResizingMode: String {
    case Scale
    case AspectFit
    case AspectFill
}

open class ImageResizing: ImagePluginType {
    fileprivate let mode: ImageResizingMode
    fileprivate let size: CGSize
    
    open var imagePluginKey: String {
        return mode.rawValue + String(describing: size.width) + String(describing: size.height)
    }
    
    open func transform(image: UIImage) throws -> UIImage {
        switch mode {
        case .Scale:
            return image.af_imageScaled(to: size)
        case .AspectFit:
            return image.af_imageAspectScaled(toFit: size)
        case .AspectFill:
            return image.af_imageAspectScaled(toFill: size)
        }
    }
    
    public init(size: CGSize, mode: ImageResizingMode = .Scale) {
        self.size = size
        self.mode = mode;
    }
}
