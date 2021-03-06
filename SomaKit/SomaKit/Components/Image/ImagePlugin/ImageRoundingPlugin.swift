//
//  ImageRoundingPlugin.swift
//  SomaKit
//
//  Created by Anton on 28.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import AlamofireImage
import RxSwift

public class ImageRoundingPlugin: ImagePluginType {
    public enum Mode {
        case cicrular
        case corners(radius: CGFloat)
        
        static var `default`: Mode {
            return .cicrular
        }
        
        public var key: String {
            switch self {
            case .cicrular:
                return "Circular"
            case .corners(let radius):
                return "Corners" + String(describing: radius)
            }
        }
    }
    
    private let mode: Mode
    
    public var pluginKey: String {
        return mode.key
    }
    
    public func perform(image: UIImage) throws -> UIImage {
        switch mode {
        case .cicrular:
            return image.af_imageRoundedIntoCircle()
        case .corners(let radius):
            return image.af_imageRounded(withCornerRadius: radius)
        }
    }
    
    public init(mode: Mode = .default) {
        self.mode = mode;
    }
}

public extension ImageOperation {
    public func round(mode: ImageRoundingPlugin.Mode = .default) -> ImageOperation {
        return ImagePluginOperation(originalOperation: self, plugin: ImageRoundingPlugin(mode: mode))
    }
}
