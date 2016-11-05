//
//  CacheStore.swift
//  SomaKit
//
//  Created by Anton on 26.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public enum CacheLifeTimeType {
    public typealias TimeGenerator = (Void) -> CacheTimeType
    
    case never
    case forever
    case value(lifeTime: CacheTimeType, timeGenerator: TimeGenerator)
}

open class CacheBase<TKey, TData>: StoreType {
    public typealias KeyType = TKey
    public typealias DataType = TData
    public typealias CacheDataType = CacheValue<DataType>

    private let sourceStore: Store<TKey, CacheDataType>
    private let lifeTimeType: CacheLifeTimeType
    
    open func loadData(_ key: KeyType) throws -> DataType? {
        if case .never = lifeTimeType {
            return nil
        }
        
        guard let cacheData = try sourceStore.loadData(key) else {
            return nil
        }
        
        return isActualCache(cacheData) ? cacheData.data : nil
    }
    
    open func saveData(_ key: KeyType, data: DataType?) throws {
        if case .never = lifeTimeType {
            return
        }
        
        guard let data = data else {
            try sourceStore.saveData(key, data: nil)
            return
        }
        
        let cacheValue = CacheValue(data: data, creationTime:currentTime())
        try sourceStore.saveData(key, data: cacheValue)
    }
    
    public init<TStore: StoreType>(sourceStore: TStore, lifeTimeType: CacheLifeTimeType = .forever) where TStore.KeyType == KeyType, TStore.DataType == CacheDataType {
        self.sourceStore = sourceStore.asStore()
        self.lifeTimeType = lifeTimeType
    }
    
    private func currentTime() -> Double {
        if case .value(_, let timeGenerator) = lifeTimeType {
            return timeGenerator()
        }
        
        return 0
    }
    
    private func isActualCache(_ cacheData: CacheDataType) -> Bool {
        switch lifeTimeType {
        case .forever:
            return true
        case .value(let lifeTime, let timeGenerator):
            if cacheData.creationTime + lifeTime < timeGenerator() {
                return true
            } else {
                return false
            }
        case .never:
            return false
        }
    }
}
