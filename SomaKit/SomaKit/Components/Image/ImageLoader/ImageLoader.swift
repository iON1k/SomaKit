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
    
    private let imageCache: Store<String, UIImage>
    private let processedImageCache = MemoryCache<String, UIImage>()
    private var loadingObservablesCache = [String : Observable<UIImage>]()
    
    private let loadingSyncLock = Sync.Lock()
    
    public func loadImage(key: TKey) -> ImageOperation {
        let loadingObservable = Observable.deferred({ () -> Observable<UIImage> in
            let imageCacheKey = key.description
            
            return self.imageCache.loadData(key: imageCacheKey)
                .flatMap({ (image) -> Observable<UIImage> in
                    if let image = image {
                        return Observable.just(image)
                    } else {
                        return self.loadingImageObservable(key: key, imageCacheKey: imageCacheKey)
                    }
                })
        })
        .subcribeOnBackgroundScheduler()
        
        return ImageLoadingOperation(imageLoader: self, key: key, loadingObservable: loadingObservable)
    }
    
    internal func performImageOperation(operation: ImageOperation) -> Observable<UIImage> {
        return Observable.deferred({ () -> Observable<UIImage> in
            let operationCachingKey = operation._cachingKey
            
            return self.processedImageCache.loadData(key: operationCachingKey)
                .observeOnBackgroundScheduler()
                .flatMap({ (cachedImage) -> Observable<UIImage> in
                    if let cachedImage = cachedImage {
                        return Observable.just(cachedImage)
                    } else {
                        return operation._workingObservable
                            .flatMap({ (processedImage) -> Observable<UIImage> in
                                return self.processedImageCache.storeData(key: operationCachingKey, data: processedImage)
                                    .observeOnBackgroundScheduler()
                                    .mapWith(processedImage)
                            })
                    }
                })
            })
            .subcribeOnBackgroundScheduler()
    }
    
    private func loadingImageObservable(key: TKey, imageCacheKey: String) -> Observable<UIImage> {
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
    
    public init<TSource: ImageSourceType, TImageCache: StoreType>
        (imageSource: TSource, imageCache: TImageCache)
        where TSource.KeyType == TKey, TImageCache.KeyType == String, TImageCache.DataType == UIImage {
        self.imageSource = imageSource.asImageSource()
        self.imageCache = imageCache.asStore()
    }
}
