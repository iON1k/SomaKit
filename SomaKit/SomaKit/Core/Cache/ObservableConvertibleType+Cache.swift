//
//  ObservableConvertibleType+Cache.swift
//  SomaKit
//
//  Created by Anton on 27.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public extension ObservableConvertibleType where Self: CachingKeyProvider {
    public func asCacheableProvider<TCacheStore: StoreType>(_ cacheStore: TCacheStore,
                                    behavior: CacheableDataProviderBehavior = .default) -> CacheableDataProvider<CachingKeyType, E>
        where TCacheStore.KeyType == CachingKeyType,
        TCacheStore.DataType == E {
        return CacheableDataProvider(dataSource: self, cacheStore: cacheStore, cacheKey: cachingKey, behavior: behavior)
    }
}
