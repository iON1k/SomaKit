//
//  AnyImageSource.swift
//  SomaKit
//
//  Created by Anton on 27.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

open class AnyImageSource<TKey: StringKeyConvertiable>: ImageSourceType {
    public typealias KeyType = TKey
    
    fileprivate let sourceLoadImageHandler: (KeyType) -> Observable<UIImage>
    
    open func loadImage(_ key: KeyType) -> Observable<UIImage> {
        return sourceLoadImageHandler(key)
    }
    
    public init<TSource: ImageSourceType>(source: TSource) where TSource.KeyType == KeyType {
        sourceLoadImageHandler = source.loadImage
    }
}

extension AnyImageSource {
    public func asImageSource() -> AnyImageSource<KeyType> {
        return self
    }
}
