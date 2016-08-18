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

public class ImageResizing: ImagePluginType {
    private let mode: ImageResizingMode
    private let size: CGSize
    
    public var imagePluginKey: String {
        return mode.rawValue + String(size.width) + String(size.height)
    }
    
    public func transform(image: UIImage) throws -> UIImage {
        switch mode {
        case .Scale:
            return image.af_imageScaledToSize(size)
        case .AspectFit:
            return image.af_imageAspectScaledToFitSize(size)
        case .AspectFill:
            return image.af_imageAspectScaledToFillSize(size)
        }
    }
    
    public init(size: CGSize, mode: ImageResizingMode = .Scale) {
        self.size = size
        self.mode = mode;
    }
}