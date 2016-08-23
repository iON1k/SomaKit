//
//  DataProviderType+Cache.swift
//  SomaKit
//
//  Created by Anton on 27.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public extension DataProviderConvertibleType where Self: CachingKeyProvider {
    public func asCacheableProvider<TCacheStore: StoreConvertibleType
        where TCacheStore.KeyType == CachingKeyType,
        TCacheStore.DataType == DataType>(cacheStore: TCacheStore, behavior: CacheableDataProviderBehavior<DataType>
        = CacheableDataProviderBehaviors.dataOrCache()) -> CacheableDataProvider<CachingKeyType, DataType> {
        return CacheableDataProvider(sourceProvider: self, cacheStore: cacheStore, cacheKey: cachingKey, behavior: behavior)
    }
}
