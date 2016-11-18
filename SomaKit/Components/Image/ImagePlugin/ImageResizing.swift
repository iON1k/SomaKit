//
//  ImageResizing.swift
//  SomaKit
//
//  Created by Anton on 28.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import AlamofireImage
import RxSwift

public enum ImageResizingMode: String {
    case Scale
    case AspectFit
    case AspectFill
}

public class ImageResizing: ImagePluginType {
    private let mode: ImageResizingMode
    private let size: CGSize
    
    public var imagePluginKey: String {
        return mode.rawValue + String(describing: size.width) + String(describing: size.height)
    }
    
    public func perform(image: UIImage) -> Observable<UIImage> {
        return Observable.deferred({ () -> Observable<UIImage> in
            return Observable.just(self.beginPerform(image: image))
        })
    }
    
    private func beginPerform(image: UIImage) -> UIImage {
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
