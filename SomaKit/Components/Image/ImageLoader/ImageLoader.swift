//
//  ImageLoader.swift
//  SomaKit
//
//  Created by Anton on 27.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public class ImageLoader<TKey: StringKeyConvertiable> {
    private let imageSource: AnyImageSource<TKey>
    
    private let imageCache: AnyStore<String, UIImage>
    private let processedImageCache: AnyStore<String, UIImage>
    
    public func loadImage(key: TKey, placeholder: UIImage? = nil, plugins: [ImagePluginType] = []) -> Observable<UIImage> {
        return Observable.deferred({ () -> Observable<UIImage> in
            let imageCacheKey = key.stringKey
            let processedImageCacheKey = self.pluginsCachingKey(imageCacheKey, plugins: plugins)
            
            if let processedImage = self.tryLoadImageFromCache(self.processedImageCache, cacheKey: processedImageCacheKey) {
                return Observable.just(processedImage)
            }
            
            if let sourceImage = self.tryLoadImageFromCache(self.imageCache, cacheKey: imageCacheKey) {
                let processedImage = try sourceImage.performPlugins(plugins)
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
    
    private func sourceLoadingImageObservable(key: TKey, imageCacheKey: String, processedImageCacheKey: String, plugins: [ImagePluginType]) -> Observable<UIImage> {
        return imageSource.loadImage(key)
            .observeOnBackgroundScheduler()
            .doOnNext({ (image) in
                self.imageCache.saveDataAsync(imageCacheKey, data: image)
            })
            .doOnNext({ (sourceImage) in
                let processedImage = try sourceImage.performPlugins(plugins)
                self.saveProcessedImageIfNeeded(processedImageCacheKey, processedImage: processedImage, sourceImage: sourceImage)
            })
    }
    
    private func tryLoadImageFromCache(imageCache: AnyStore<String, UIImage>, cacheKey: String) -> UIImage? {
        do {
            return try imageCache.loadData(cacheKey)
        } catch let error {
            Log.log(error)
        }
        
        return nil
    }
    
    private func saveProcessedImageIfNeeded(processedImageCacheKey: String, processedImage: UIImage, sourceImage: UIImage) {
        if sourceImage !== processedImage {
            processedImageCache.saveDataAsync(processedImageCacheKey, data: processedImage)
        }
    }
    
    private func pluginsCachingKey(imageCacheKey: String, plugins: [ImagePluginType]) -> String {
        var cachingKey = imageCacheKey
        
        for plugin in plugins {
            cachingKey += plugin.imagePluginKey
        }
        
        return cachingKey
    }
    
    public init<TSource: ImageSourceConvertiable, TImageCache: StoreConvertibleType, TProcessedImageCache: StoreConvertibleType
        where TSource.KeyType == TKey, TImageCache.KeyType == String, TImageCache.DataType == UIImage,
        TProcessedImageCache.KeyType == String, TProcessedImageCache.DataType == UIImage>
        (imageSource: TSource, imageCache: TImageCache, processedImageCache: TProcessedImageCache) {
        self.imageSource = imageSource.asAnyImageSource()
        self.imageCache = imageCache.asAnyStore()
        self.processedImageCache = processedImageCache.asAnyStore()
    }
}

extension ImageLoader {
    public func loadImage(key: TKey, placeholder: UIImage?, plugins: ImagePluginType ...) -> Observable<UIImage> {
        return self.loadImage(key, placeholder:placeholder, plugins: plugins)
    }
    
    public func loadImage(key: TKey, plugins: ImagePluginType ...) -> Observable<UIImage> {
        return self.loadImage(key, placeholder:nil, plugins: plugins)
    }
}
