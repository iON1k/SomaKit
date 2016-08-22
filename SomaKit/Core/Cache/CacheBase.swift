//
//  CacheStore.swift
//  SomaKit
//
//  Created by Anton on 26.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public enum CacheLifeTimeType {
    public typealias TimeGenerator = Void -> CacheTimeType
    
    case Forever
    case Value(lifeTime: CacheTimeType, timeGenerator: TimeGenerator)
}

public class CacheBase<TKey, TData>: StoreType {
    public typealias KeyType = TKey
    public typealias DataType = TData
    public typealias CacheDataType = CacheValue<DataType>

    private let sourceStore: AnyStore<TKey, CacheDataType>
    private let lifeTimeType: CacheLifeTimeType
    
    public func loadData(key: KeyType) throws -> DataType? {
        guard let cacheData = try sourceStore.loadData(key) else {
            return nil
        }
        
        return isActualCache(cacheData) ? cacheData.data : nil
    }
    
    public func saveData(key: KeyType, data: DataType) throws {
        let cacheValue = CacheValue(data: data, creationTime:currentTime())
        try sourceStore.saveData(key, data: cacheValue)
    }
    
    public init<TStore: StoreConvertibleType where TStore.KeyType == KeyType, TStore.DataType == CacheDataType>(sourceStore: TStore, lifeTimeType: CacheLifeTimeType = .Forever) {
        self.sourceStore = sourceStore.asStore()
        self.lifeTimeType = lifeTimeType
    }
    
    private func currentTime() -> Double {
        if case .Value(_, let timeGenerator) = lifeTimeType {
            return timeGenerator()
        }
        
        return 0
    }
    
    private func isActualCache(cacheData: CacheDataType) -> Bool {
        switch lifeTimeType {
        case .Forever:
            return true
        case .Value(let lifeTime, let timeGenerator):
            if cacheData.creationTime + lifeTime < timeGenerator() {
                return true
            } else {
                return false
            }
        }
    }
}
