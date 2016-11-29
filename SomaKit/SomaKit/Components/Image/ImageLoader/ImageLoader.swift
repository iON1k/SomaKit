//
//  ImageLoader.swift
//  SomaKit
//
//  Created by Anton on 27.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public class ImageLoader<TKey: CustomStringConvertible> {
    private let imageSource: ImageSource<TKey>
    private let imageCache: MemoryStore<String, UIImage>
    
    private let loadingSyncLock = Sync.Lock()
    
    public func loadImage(key: TKey) -> ImageOperation {
        let loadingObservable = self.imageSource
            .loadImage(key)
            .subcribeOnBackgroundScheduler()
        
        return ImageLoadingOperation(imageLoader: self, key: key, loadingObservable: loadingObservable)
    }
    
    internal func performImageOperation(operation: ImageOperation) -> Observable<UIImage> {
        return Observable.deferred({ () -> Observable<UIImage> in
            let operationCachingKey = operation._cachingKey
            
            return self.imageCache.loadData(key: operationCachingKey)
                .observeOnBackgroundScheduler()
                .flatMap({ (cachedImage) -> Observable<UIImage> in
                    if let cachedImage = cachedImage {
                        return Observable.just(cachedImage)
                    } else {
                        return operation._imageSource
                            .flatMap({ (imageData) -> Observable<UIImage> in
                                let operationImage = imageData.operationImage
                                if operationImage == imageData.sourceImage {
                                    return Observable.just(operationImage)
                                } else {
                                    return self.imageCache.storeData(key: operationCachingKey, data: operationImage)
                                        .observeOnBackgroundScheduler()
                                        .mapWith(operationImage)
                                }
                                
                                
                            })
                    }
                })
            })
            .subcribeOnBackgroundScheduler()
    }
    
    public init<TSource: ImageSourceType>(imageSource: TSource,
                imageCache: MemoryStore<String, UIImage> = MemoryStore()) where TSource.KeyType == TKey {
        self.imageSource = imageSource.asImageSource()
        self.imageCache = imageCache
    }
}
