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
    public typealias ProcessedCacheType = MemoryCache<String, UIImage>
    public typealias LoadingObservableCacheType = [String : Observable<UIImage>]
    
    private let imageCache: Store<String, UIImage>
    private let processedImageCache: ProcessedCacheType
    private var loadingObservableCache = LoadingObservableCacheType()
    
    private let loadingSyncLock = Sync.Lock()
    
    public func loadImage(key: TKey, plugins: [ImagePluginType] = []) -> Observable<UIImage> {
        return Observable.deferred({ () -> Observable<UIImage> in
            let imageCacheKey = key.description
            let processedImageCacheKey = self.pluginsCachingKey(imageCacheKey, plugins: plugins)
            
            return self.processedImageCache.loadData(key: processedImageCacheKey)
                .flatMap({ (processedImage) -> Observable<UIImage?> in
                    if let processedImage = processedImage {
                        return Observable.just(processedImage)
                    } else {
                        return self.imageCache.loadData(key: imageCacheKey)
                    }
                })
                .flatMap({ (sourceImage) -> Observable<UIImage> in
                    if let sourceImage = sourceImage {
                        return self.processAndCacheSourceImage(sourceImage: sourceImage, plugins: plugins, processedImageCacheKey: processedImageCacheKey)
                    } else {
                        return self.sourceLoadingImageObservable(key: key, imageCacheKey: imageCacheKey,
                                                                              processedImageCacheKey: processedImageCacheKey, plugins: plugins)
                    }
                })
        })
        .subcribeOnBackgroundScheduler()
    }
    
    private func sourceLoadingImageObservable(key: TKey, imageCacheKey: String,
                                              processedImageCacheKey: String, plugins: [ImagePluginType]) -> Observable<UIImage> {
        return loadingSyncLock.sync {
            if let loadingObservable = loadingObservableCache[imageCacheKey] {
                return loadingObservable
            }
            
            let loadingObservable = imageSource.loadImage(key)
                .flatMap({ (image) -> Observable<UIImage> in
                    return self.imageCache.storeData(key: imageCacheKey, data: image)
                        .mapWith(image)
                })
                .flatMap({ (image) -> Observable<UIImage> in
                    return self.processAndCacheSourceImage(sourceImage: image, plugins: plugins, processedImageCacheKey: processedImageCacheKey)
                })
                .do(onDispose: { 
                    self.removeLoadingObservable(cacheKey: imageCacheKey)
                })
                .share()
            
            loadingObservableCache[imageCacheKey] = loadingObservable
            
            return loadingObservable
        }
    }
    
    private func removeLoadingObservable(cacheKey: String) {
        loadingSyncLock.sync {
            loadingObservableCache.removeValue(forKey: cacheKey)
            return
        }
    }
    
    private func processAndCacheSourceImage(sourceImage: UIImage, plugins: [ImagePluginType], processedImageCacheKey: String) -> Observable<UIImage> {
        return sourceImage.performPlugins(plugins: plugins)
            .flatMap({ (processedImage) -> Observable<UIImage> in
                if sourceImage !== processedImage {
                    return self.processedImageCache.storeData(key: processedImageCacheKey, data: processedImage)
                        .mapWith(processedImage)
                } else {
                    return Observable.just(processedImage)
                }
            })
    }
    
    private func pluginsCachingKey(_ imageCacheKey: String, plugins: [ImagePluginType]) -> String {
        var cachingKey = imageCacheKey
        
        for plugin in plugins {
            cachingKey += plugin.imagePluginKey
        }
        
        return cachingKey
    }
    
    public init<TSource: ImageSourceType, TImageCache: StoreType>
        (imageSource: TSource, imageCache: TImageCache, processedImageCache: ProcessedCacheType = MemoryCache())
        where TSource.KeyType == TKey, TImageCache.KeyType == String, TImageCache.DataType == UIImage {
        self.imageSource = imageSource.asImageSource()
        self.imageCache = imageCache.asStore()
        self.processedImageCache = processedImageCache
    }
}

extension ImageLoader {
    public func loadImage(key: TKey, plugins: ImagePluginType ...) -> Observable<UIImage> {
        return self.loadImage(key: key, plugins: plugins)
    }
}
