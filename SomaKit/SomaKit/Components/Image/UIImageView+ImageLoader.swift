//
//  UIImageView+ImageLoader.swift
//  SomaKit
//
//  Created by Anton on 23.11.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import UIKit
import RxSwift

public extension ImagePlugins.Resizing.Mode {
    public static func fromUIContentMode(contentMode: UIViewContentMode) -> ImagePlugins.Resizing.Mode {
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
                          placeholder: UIImage? = nil, plugins: [ImagePluginType] = []) -> Observable<UIImage> {
        
        var resultPlugins = [ImagePluginType]()
        
        if resizeImage {
            resultPlugins.append(ImagePlugins.Resizing(size: frame.size, mode: ImagePlugins.Resizing.Mode.fromUIContentMode(contentMode: contentMode)))
        }
        
        resultPlugins += plugins
        
        var resultObservable = loader.loadImage(key: key, plugins: resultPlugins)
            .observeOnMainScheduler()
            .do(onNext: { [weak self] (image) in
                self?.image = image
            })
            .takeUntil(self.rx.deallocated)
        
        if let placeholder = placeholder {
            resultObservable = resultObservable.startWith(placeholder)
        }
        
        return resultObservable
    }
    
    public func loadImage<TKey: CustomStringConvertible>(key: TKey, loader: ImageLoader<TKey>, resizeImage: Bool = true,
                          placeholder: UIImage? = nil, plugins: ImagePluginType ...) -> Observable<UIImage> {
        return loadImage(key: key, loader: loader, resizeImage: resizeImage, placeholder: placeholder, plugins: plugins)
    }
}
