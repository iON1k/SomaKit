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
            
            if let processedImage = self.tryLoadImageFromCache(self.processedImageCache, cacheKey: processedImageCacheKey) {
                return Observable.just(processedImage)
            }
            
            if let sourceImage = self.tryLoadImageFromCache(self.imageCache, cacheKey: imageCacheKey) {
                let processedImage = try sourceImage.performPlugins(plugins: plugins)
                self.saveProcessedImageIfNeeded(processedImageCacheKey, processedImage: processedImage, sourceImage: sourceImage)
                
                return Observable.just(processedImage)
            }
            
            let sourceLoading = self.sourceLoadingImageObservable(key, imageCacheKey: imageCacheKey, processedImageCacheKey: processedImageCacheKey, plugins: plugins)
            
            if let placeholder = placeholder {
                return sourceLoading
                    .startWith(placeholder)
            }
            
            return sourceLoading
            
        })
        .subcribeOnBackgroundScheduler()
    }
    
    private func sourceLoadingImageObservable(_ key: TKey, imageCacheKey: String, processedImageCacheKey: String, plugins: [ImagePluginType]) -> Observable<UIImage> {
        return imageSource.loadImage(key)
            .observeOnBackgroundScheduler()
            .do(onNext: { (image) in
                _ = self.imageCache.saveDataInBackground(imageCacheKey, data: image)
            })
            .do(onNext: { (sourceImage) in
                let processedImage = try sourceImage.performPlugins(plugins: plugins)
                self.saveProcessedImageIfNeeded(processedImageCacheKey, processedImage: processedImage, sourceImage: sourceImage)
            })
    }
    
    private func tryLoadImageFromCache(_ imageCache: Store<String, UIImage>, cacheKey: String) -> UIImage? {
        return Utils.safe {
            return try imageCache.loadData(cacheKey)
        }
    }
    
    private func saveProcessedImageIfNeeded(_ processedImageCacheKey: String, processedImage: UIImage, sourceImage: UIImage) {
        if sourceImage !== processedImage {
            _ = processedImageCache.saveDataInBackground(processedImageCacheKey, data: processedImage)
        }
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
