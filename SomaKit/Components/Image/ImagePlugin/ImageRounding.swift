//
//  ImageRounding.swift
//  SomaKit
//
//  Created by Anton on 28.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import AlamofireImage

public enum ImageRoundingMode {
    case Cicrular
    case Corners(radius: CGFloat)
    
    public var imagePluginKey: String {
        switch self {
        case .Cicrular:
            return "Circular"
        case .Corners(let radius):
            return "Corners" + String(radius)
        }
    }
}

public class ImageRounding: ImagePluginType {
    private let mode: ImageRoundingMode
    
    public var imagePluginKey: String {
        return mode.imagePluginKey
    }
    
    public func transform(image: UIImage) throws -> UIImage {
        switch mode {
        case .Cicrular:
            return image.af_imageRoundedIntoCircle()
        case .Corners(let radius):
            return image.af_imageWithRoundedCornerRadius(radius)
        }
    }
    
    public init(mode: ImageRoundingMode = .Cicrular) {
        self.mode = mode;
    }
}