//
//  UIImageView+ImageLoader.swift
//  SomaKit
//
//  Created by Anton on 23.11.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import UIKit
import RxSwift

public extension ImageResizingMode {
    public static func fromUIContentMode(contentMode: UIViewContentMode) -> ImageResizingMode {
        switch contentMode {
        case .scaleAspectFill:
            return .AspectFill
        case .scaleAspectFit:
            return .AspectFit
        default:
            return .Scale
        }
    }
}

public extension UIImageView {
    public func loadImage<TKey: CustomStringConvertible>(key: TKey, loader: ImageLoader<TKey>, resizeImage: Bool = true,
                          placeholder: UIImage? = nil, plugins: ImagePluginType ...) -> Observable<UIImage> {
        
        var resultPlugins = plugins
        if resizeImage {
            resultPlugins.append(ImageResizing(size: frame.size, mode: ImageResizingMode.fromUIContentMode(contentMode: contentMode)))
        }
        
        var resultObservable = loader.loadImage(key: key, plugins: resultPlugins)
            .do(onNext: { [weak self] (image) in
                self?.image = image
            })
            .takeUntil(self.rx.deallocated)
        
        if let placeholder = placeholder {
            resultObservable = resultObservable.startWith(placeholder)
        }
        
        return resultObservable
    }
}
