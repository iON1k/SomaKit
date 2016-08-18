//
//  RequestType+Cache.swift
//  SomaKit
//
//  Created by Anton on 27.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public extension RequestType where Self: CachingKeyProvider {
    public func asCacheableProvider<TCacheStore: StoreConvertibleType
        where TCacheStore.KeyType == String,
        TCacheStore.DataType == ResponseType>(cacheStore: TCacheStore, behavior: CacheableDataProviderBehavior<ResponseType>
        = CacheableDataProviderBehaviors.dataOrCache()) -> CacheableDataProvider<String, ResponseType> {
        return CacheableDataProvider(sourceProvider: self.asAnyDataProvider(), cacheStore: cacheStore, cacheKey: self.cachingKey, behavior: behavior)
    }
}
