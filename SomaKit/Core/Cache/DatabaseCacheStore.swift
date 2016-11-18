//
//  DatabaseCacheStore.swift
//  SomaKit
//
//  Created by Anton on 26.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import CoreData

public class DatabaseCacheStore<TData, TDatabase: CacheManagedObject>: AbstractDatabaseStore<String, CacheValue<TData>, TDatabase> {
    public typealias GetterCacheHandlerType = (TDatabase) throws -> TData
    
    public init(dbContext: NSManagedObjectContext, setterHandler: @escaping SetterHandlerType, getterHandler: @escaping GetterCacheHandlerType) {
        super.init(dbContext: dbContext, keyProperty: CacheManagedObject.DefaultCacheKey, setterHandler: { (data, record) in
                try setterHandler(data, record)
            }) { (record) -> CacheValue<TData> in
                let data = try getterHandler(record)
                return CacheValue(data: data, creationTime: record.creationTime)
            }
    }
}
