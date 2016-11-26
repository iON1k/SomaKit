//
//  ImageLoadingOperation.swift
//  SomaKit
//
//  Created by Anton on 25.11.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public class ImageLoadingOperation<TKey: CustomStringConvertible>: ImageOperation, ImageOperationPerformer {
    public override var _workingObservable: Observable<UIImage> {
        return loadingObservable
    }
    
    public override var _performer: ImageOperationPerformer {
        return self
    }
    
    public override var _cachingKey: String {
        return key.description
    }
    
    public func performImageOperation(operation: ImageOperation) -> Observable<UIImage> {
        return imageLoader.performImageOperation(operation: operation)
    }

    private let loadingObservable: Observable<UIImage>
    private let imageLoader: ImageLoader<TKey>
    private let key: TKey
    
    public init(imageLoader: ImageLoader<TKey>, key: TKey, loadingObservable: Observable<UIImage>) {
        self.imageLoader = imageLoader
        self.key = key
        self.loadingObservable = loadingObservable
    }
}
