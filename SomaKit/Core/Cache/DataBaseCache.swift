//
//  DataBaseCache.swift
//  SomaKit
//
//  Created by Anton on 26.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public class DataBaseCache<TData, TDataBase: CacheManagedObject>: AbstractDataBaseStore<String, CacheValue<TData>, TDataBase> {
    public typealias GetterCacheHandlerType = TDataBase throws -> TData
    
    public init(setterHandler: SetterHandlerType, getterHandler: GetterCacheHandlerType) {
        super.init(keyProperty: CacheManagedObject.DefaultCacheKey, setterHandler: { (data, record) in
                try setterHandler(data, record)
            }) { (record) -> CacheValue<TData> in
                let data = try getterHandler(record)
                return CacheValue(data: data, creationTimestamp: record.creationTimestamp)
            }
    }
}

//extension DataBaseCache {
//    public func asCacheStore(cacheLifeTime: CacheLifeTime = .Forever) -> CacheStore<KeyType, TData> {
//        return CacheStore(sourceStore: self, cacheLifeTime: cacheLifeTime)
//    }
//}