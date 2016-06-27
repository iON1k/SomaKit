//
//  ImageLoader.swift
//  SomaKit
//
//  Created by Anton on 27.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public class ImageLoader<TKey: ImageLoaderKeyType> {
    private let imageSource: AnyImageSource<TKey>
    
    private let scheduler = ConcurrentDispatchQueueScheduler(globalConcurrentQueueQOS: .Default)
    
    private let imageCache: AnyStore<String, UIImage>
    private let processedImageCache: AnyStore<String, UIImage>
    
    public func loadImage(key: TKey, plugins: ImagePlugin ...) -> Observable<UIImage> {
        return Observable.deferred({ () -> Observable<UIImage> in
            let imageCacheKey = key.imageLoaderCacheKey
            let processedImageCacheKey = self.pluginsCachingKey(key, plugins: plugins)
            
            if let processedImage = self.tryLoadImageFromCache(self.processedImageCache, cacheKey: processedImageCacheKey) {
                return Observable.just(processedImage)
            }
            
            if let sourceImage = self.tryLoadImageFromCache(self.imageCache, cacheKey: imageCacheKey) {
                let processedImage = try self.processSourceImage(sourceImage, plugins: plugins)
                self.processedImageCache.saveDataAsync(processedImageCacheKey, data: processedImage)
                return Observable.just(processedImage)
            }
            
            return self.sourceLoadingImageObservable(key, plugins: plugins)
            
        })
        .subscribeOn(scheduler)
    }
    
    private func sourceLoadingImageObservable(key: TKey, plugins: [ImagePlugin]) -> Observable<UIImage> {
        return imageSource.loadImage(key)
            .observeOn(scheduler)
            .doOnNext({ (image) in
                let imageCacheKey = key.imageLoaderCacheKey
                self.imageCache.saveDataAsync(imageCacheKey, data: image)
            })
            .map({ (image) -> UIImage in
                return try self.processSourceImage(image, plugins: plugins)
            })
            .doOnNext({ (processedImage) in
                let processedImageCacheKey = self.pluginsCachingKey(key, plugins: plugins)
                self.processedImageCache.saveDataAsync(processedImageCacheKey, data: processedImage)
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
    
    private func processSourceImage(sourceImage: UIImage, plugins: [ImagePlugin]) throws -> UIImage {
        var processedImage = sourceImage
        
        for plugin in plugins {
            processedImage = try plugin.transform(processedImage)
        }
        
        return processedImage
    }
    
    private func pluginsCachingKey(imageCacheKey: TKey, plugins: [ImagePlugin]) -> String {
        var cachingKey = imageCacheKey.imageLoaderCacheKey
        
        for plugin in plugins {
            cachingKey += plugin.cachingKey
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