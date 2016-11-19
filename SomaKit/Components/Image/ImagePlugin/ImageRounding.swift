//
//  ImageRounding.swift
//  SomaKit
//
//  Created by Anton on 28.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import AlamofireImage
import RxSwift

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

public class ImageRounding: ImagePluginType {
    private let mode: ImageRoundingMode
    
    public var imagePluginKey: String {
        return mode.imagePluginKey
    }
    
    public func perform(image: UIImage) -> Observable<UIImage> {
        return Observable.deferred({ () -> Observable<UIImage> in
            return Observable.just(self.beginPerform(image: image))
        })
        .subcribeOnBackgroundScheduler()
    }
    
    private func beginPerform(image: UIImage) -> UIImage {
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
