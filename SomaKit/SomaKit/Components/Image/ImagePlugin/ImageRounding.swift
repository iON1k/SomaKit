//
//  ImageRounding.swift
//  SomaKit
//
//  Created by Anton on 28.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import AlamofireImage
import RxSwift

public extension ImagePlugins {
    public class Rounding: ImagePluginType {
        public enum Mode {
            case cicrular
            case corners(radius: CGFloat)
            
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
        
        public var imagePluginKey: String {
            return mode.key
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
        
        public init(mode: Mode = .cicrular) {
            self.mode = mode;
        }
    }
}
