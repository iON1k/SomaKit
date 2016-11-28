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
    
    private var loadingObservablesCache = [String : Observable<UIImage>]()
    
    private let loadingSyncLock = Sync.Lock()
    
    public func loadImage(key: TKey) -> ImageOperation {
        let loadingObservable = Observable.deferred({ () -> Observable<UIImage> in
            let imageCacheKey = key.description
            return self.beginLoadingImage(key: key, imageCacheKey: imageCacheKey)
        })
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
                            .flatMap({ (processedImage) -> Observable<UIImage> in
                                return self.imageCache.storeData(key: operationCachingKey, data: processedImage)
                                    .observeOnBackgroundScheduler()
                                    .mapWith(processedImage)
                            })
                    }
                })
            })
            .subcribeOnBackgroundScheduler()
    }
    
    private func beginLoadingImage(key: TKey, imageCacheKey: String) -> Observable<UIImage> {
        return loadingSyncLock.sync {
            if let loadingObservable = loadingObservablesCache[imageCacheKey] {
                return loadingObservable
            }
            
            let loadingObservable = imageSource.loadImage(key)
                .observeOnBackgroundScheduler()
                .do(onDispose: {
                    self.removeLoadingObservable(cacheKey: imageCacheKey)
                })
                .shareReplay(1)
            
            loadingObservablesCache[imageCacheKey] = loadingObservable
            
            return loadingObservable
        }
    }
    
    private func removeLoadingObservable(cacheKey: String) {
        loadingSyncLock.sync {
            loadingObservablesCache.removeValue(forKey: cacheKey)
            return
        }
    }
    
    public init<TSource: ImageSourceType>(imageSource: TSource,
                imageCache: MemoryStore<String, UIImage> = MemoryStore()) where TSource.KeyType == TKey {
        self.imageSource = imageSource.asImageSource()
        self.imageCache = imageCache
    }
}
