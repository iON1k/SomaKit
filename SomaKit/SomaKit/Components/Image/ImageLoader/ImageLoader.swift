//
//  ImageLoader.swift
//  SomaKit
//
//  Created by Anton on 27.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public final class ImageLoader<TKey: CustomStringConvertible> {
    private let imageSource: ImageSource<TKey>
    private let imageCache: Store<String, UIImage>
    
    public func loadImage(key: TKey) -> ImageOperation {
        return ImageLoadingOperation(key: key, imageSource: imageSource.loadImage(key), cache: imageCache)
    }
    
    public init<TSource: ImageSourceType, TCache: StoreType>(imageSource: TSource,
                imageCache: TCache) where TSource.KeyType == TKey, TCache.KeyType == String, TCache.DataType == UIImage {
        self.imageSource = imageSource.asImageSource()
        self.imageCache = imageCache.asStore()
    }
    
    public convenience init<TSource: ImageSourceType>(imageSource: TSource) where TSource.KeyType == TKey {
        self.init(imageSource: imageSource, imageCache: MemoryCache())
    }
}
