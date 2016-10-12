//
//  DataBaseCacheStore.swift
//  SomaKit
//
//  Created by Anton on 26.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

open class DataBaseCacheStore<TData, TDataBase: CacheManagedObject>: AbstractDataBaseStore<String, CacheValue<TData>, TDataBase> {
    public typealias GetterCacheHandlerType = (TDataBase) throws -> TData
    
    public init(setterHandler: @escaping SetterHandlerType, getterHandler: @escaping GetterCacheHandlerType) {
        super.init(keyProperty: CacheManagedObject.DefaultCacheKey, setterHandler: { (data, record) in
                try setterHandler(data, record)
            }) { (record) -> CacheValue<TData> in
                let data = try getterHandler(record)
                return CacheValue(data: data, creationTime: record.creationTime)
            }
    }
}
