//
//  ImageLoadingOperation.swift
//  SomaKit
//
//  Created by Anton on 25.11.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public class ImageLoadingOperation<TKey: CustomStringConvertible>: ImageOperation, ImageOperationPerformer {
    public override var _performer: ImageOperationPerformer {
        return self
    }
    
    public func _performImageOperation(operation: ImageOperation) -> Observable<UIImage> {
        return Observable.deferred({ () -> Observable<UIImage> in
            let cachingKey = self.key.description + operation._cachingKey
            
            return self.cache.loadData(key: cachingKey)
                .observeOnBackgroundScheduler()
                .flatMap({ (cachedImage) -> Observable<UIImage> in
                    if let cachedImage = cachedImage {
                        return Observable.just(cachedImage)
                    } else {
                        return self.beginLoadImage(operation: operation, cachingKey: cachingKey)
                    }
                })
        })
        .subcribeOnBackgroundScheduler()
    }
    
    private func beginLoadImage(operation: ImageOperation, cachingKey: String) -> Observable<UIImage> {
        return self.imageSource
            .flatMap({ (originalImage) -> Observable<UIImage> in
                return operation._begin(image: originalImage)
                    .flatMap({ (image) -> Observable<UIImage> in
                        if image == originalImage {
                            return Observable.just(image)
                        } else {
                            return self.cache.storeData(key: cachingKey, data: image)
                                .observeOnBackgroundScheduler()
                                .mapWith(image)
                        }
                    })
            })
    }

    private let imageSource: Observable<UIImage>
    private let key: TKey
    private let cache: Store<String, UIImage>
    
    public init<TCache: StoreType>(key: TKey, imageSource: Observable<UIImage>, cache: TCache) where TCache.KeyType == String, TCache.DataType == UIImage {
        self.key = key
        self.imageSource = imageSource
        self.cache = cache.asStore()
    }
}
