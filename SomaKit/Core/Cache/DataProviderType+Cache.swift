//
//  DataProviderType+Cache.swift
//  SomaKit
//
//  Created by Anton on 27.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public extension DataProviderConvertibleType where Self: StringCachingKeyProvider {
    public func asCacheableProvider<TCacheStore: StoreConvertibleType
        where TCacheStore.KeyType == String,
        TCacheStore.DataType == DataType>(cacheStore: TCacheStore, behavior: CacheableDataProviderBehavior<DataType>
        = CacheableDataProviderBehaviors.dataOrCache()) -> CacheableDataProvider<String, DataType> {
        return CacheableDataProvider(sourceProvider: self, cacheStore: cacheStore, cacheKey: stringCachingKey, behavior: behavior)
    }
}
