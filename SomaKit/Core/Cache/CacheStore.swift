//
//  CacheStore.swift
//  SomaKit
//
//  Created by Anton on 26.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public enum CacheLifeTime {
    case Forever
    case Value(lifeTime: Double)
}

public class CacheStore<TKey, TData>: StoreType {
    public typealias KeyType = TKey
    public typealias DataType = TData
    public typealias CacheDataType = CacheValue<DataType>

    private let sourceStore: AnyStore<TKey, CacheDataType>
    private let cacheLifeTime: CacheLifeTime
    
    public func loadData(key: KeyType) throws -> DataType? {
        guard let cacheData = try sourceStore.loadData(key) else {
            return nil
        }
        
        return isActualCache(cacheData) ? cacheData.data : nil
    }
    
    public func saveData(key: KeyType, data: DataType) throws {
        let cacheValue = CacheValue(data: data, creationTimestamp:currentTimestamp())
        try sourceStore.saveData(key, data: cacheValue)
    }
    
    public init<TStore: StoreConvertibleType where TStore.KeyType == KeyType, TStore.DataType == CacheDataType>(sourceStore: TStore, cacheLifeTime: CacheLifeTime = .Forever) {
        self.sourceStore = sourceStore.asAnyStore()
        self.cacheLifeTime = cacheLifeTime
    }
    
    private func currentTimestamp() -> Double {
        return NSDate.timeIntervalSinceReferenceDate()
    }
    
    private func isActualCache(cacheData: CacheDataType) -> Bool {
        switch cacheLifeTime {
        case .Forever:
            return true
        case .Value(let lifeTime):
            if cacheData.creationTimestamp + lifeTime < currentTimestamp() {
                return true
            } else {
                return false
            }
        }
    }
}