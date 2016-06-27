//
//  AnyImageSource.swift
//  SomaKit
//
//  Created by Anton on 27.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public class AnyImageSource<TKey: StringKeyConvertiable>: ImageSourceType {
    public typealias KeyType = TKey
    
    private let sourceLoadImageHandler: KeyType -> Observable<UIImage>
    
    public func loadImage(key: KeyType) -> Observable<UIImage> {
        return sourceLoadImageHandler(key)
    }
    
    public init<TSource: ImageSourceType where TSource.KeyType == KeyType>(source: TSource) {
        sourceLoadImageHandler = source.loadImage
    }
}

extension AnyImageSource {
    public func asAnyImageSource() -> AnyImageSource<KeyType> {
        return self
    }
}