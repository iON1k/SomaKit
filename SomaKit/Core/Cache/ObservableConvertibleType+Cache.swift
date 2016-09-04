//
//  ObservableConvertibleType+Cache.swift
//  SomaKit
//
//  Created by Anton on 27.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public extension ObservableConvertibleType where Self: CachingKeyProvider {
    public func asCacheableProvider<TCacheStore: StoreConvertibleType
        where TCacheStore.KeyType == CachingKeyType,
        TCacheStore.DataType == E>(cacheStore: TCacheStore, behavior: CacheableDataProviderBehavior<E>
        = CacheableDataProviderBehaviors.dataOrCache()) -> CacheableDataProvider<CachingKeyType, E> {
        return CacheableDataProvider(dataSource: self, cacheStore: cacheStore, cacheKey: cachingKey, behavior: behavior)
    }
}
