//
//  ImageLoader.swift
//  SomaKit
//
//  Created by Anton on 27.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

open class ImageLoader<TKey: CustomStringConvertible> {
    private let imageSource: ImageSource<TKey>
    
    private let imageCache: Store<String, UIImage>
    private let processedImageCache: Store<String, UIImage>
    
    open func loadImage(_ key: TKey, placeholder: UIImage? = nil, plugins: [ImagePluginType] = []) -> Observable<UIImage> {
        return Observable.deferred({ () -> Observable<UIImage> in
            let imageCacheKey = key.description
            let processedImageCacheKey = self.pluginsCachingKey(imageCacheKey, plugins: plugins)
            
            return self.processedImageCache.loadData(key: processedImageCacheKey)
                .observeOnBackgroundScheduler()
                .flatMap({ (processedImage) -> Observable<UIImage?> in
                    if let processedImage = processedImage {
                        return Observable.just(processedImage)
                    } else {
                        return self.imageCache.loadData(key: imageCacheKey)
                            .observeOnBackgroundScheduler()
                    }
                })
                .flatMap({ (sourceImage) -> Observable<UIImage> in
                    if let sourceImage = sourceImage {
                        return self.processAndCacheSourceImage(sourceImage: sourceImage, plugins: plugins, processedImageCacheKey: processedImageCacheKey)
                    } else {
                        var sourceLoading = self.sourceLoadingImageObservable(key, imageCacheKey: imageCacheKey,
                                                                              processedImageCacheKey: processedImageCacheKey, plugins: plugins)
                        
                        if let placeholder = placeholder {
                            sourceLoading = sourceLoading
                                .startWith(placeholder)
                        }
                        
                        return sourceLoading
                    }
                })
        })
        .subcribeOnBackgroundScheduler()
    }
    
    private func sourceLoadingImageObservable(_ key: TKey, imageCacheKey: String,
                                              processedImageCacheKey: String, plugins: [ImagePluginType]) -> Observable<UIImage> {
        return imageSource.loadImage(key)
            .observeOnBackgroundScheduler()
            .flatMap({ (image) -> Observable<UIImage> in
                return self.imageCache.storeData(key: imageCacheKey, data: image)
                    .mapToJust(image)
            })
            .flatMap({ (image) -> Observable<UIImage> in
                return self.processAndCacheSourceImage(sourceImage: image, plugins: plugins, processedImageCacheKey: processedImageCacheKey)
            })
    }
    
    private func processAndCacheSourceImage(sourceImage: UIImage, plugins: [ImagePluginType], processedImageCacheKey: String) -> Observable<UIImage> {
        return Observable.deferred({ () -> Observable<UIImage> in
            let processedImage = try sourceImage.performPlugins(plugins: plugins)
            if sourceImage !== processedImage {
                return self.processedImageCache.storeData(key: processedImageCacheKey, data: processedImage)
                    .observeOnBackgroundScheduler()
                    .mapToJust(processedImage)
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
    
    public init<TSource: ImageSourceType, TImageCache: StoreType, TProcessedImageCache: StoreType>
        (imageSource: TSource, imageCache: TImageCache, processedImageCache: TProcessedImageCache)
        where TSource.KeyType == TKey, TImageCache.KeyType == String, TImageCache.DataType == UIImage,
        TProcessedImageCache.KeyType == String, TProcessedImageCache.DataType == UIImage {
        self.imageSource = imageSource.asImageSource()
        self.imageCache = imageCache.asStore()
        self.processedImageCache = processedImageCache.asStore()
    }
}

extension ImageLoader {
    public func loadImage(_ key: TKey, placeholder: UIImage?, plugins: ImagePluginType ...) -> Observable<UIImage> {
        return self.loadImage(key, placeholder:placeholder, plugins: plugins)
    }
    
    public func loadImage(_ key: TKey, plugins: ImagePluginType ...) -> Observable<UIImage> {
        return self.loadImage(key, placeholder:nil, plugins: plugins)
    }
}
