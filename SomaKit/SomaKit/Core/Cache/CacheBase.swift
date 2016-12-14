//
//  CacheBase.swift
//  SomaKit
//
//  Created by Anton on 26.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public enum CacheLifeTimeBehavior {
    public typealias TimeGenerator = (Void) -> CacheTimeType
    
    case never
    case forever
    case value(lifeTime: CacheTimeType, timeGenerator: TimeGenerator)
    
    static let `default` = forever
}

open class CacheBase<TKey, TData>: StoreType {
    public typealias KeyType = TKey
    public typealias DataType = TData
    public typealias CacheDataType = CacheValue<DataType>

    private let sourceStore: Store<TKey, CacheDataType>
    private let lifeTimeBehavior: CacheLifeTimeBehavior
    
    public func loadData(key: TKey) throws -> TData? {
        if case .never = lifeTimeBehavior {
            return nil
        } else {
            if let cacheData = try sourceStore.loadData(key: key) {
                return isActualCache(cacheData) ? cacheData.data : nil
            } else {
                return nil
            }
        }
    }

    public func storeData(key: TKey, data: TData?) throws {
        if case .never = lifeTimeBehavior {
            return
        }

        guard let data = data else {
            return try sourceStore.storeData(key: key, data: nil)
        }

        let cacheValue = CacheValue(data: data, creationTime:currentTime())
        return try sourceStore.storeData(key: key, data: cacheValue)
    }

    public init<TStore: StoreType>(sourceStore: TStore, lifeTimeBehavior: CacheLifeTimeBehavior = .default) where TStore.KeyType == KeyType, TStore.DataType == CacheDataType {
        self.sourceStore = sourceStore.asStore()
        self.lifeTimeBehavior = lifeTimeBehavior
    }
    
    private func currentTime() -> Double {
        if case .value(_, let timeGenerator) = lifeTimeBehavior {
            return timeGenerator()
        }
        
        return 0
    }
    
    private func isActualCache(_ cacheData: CacheDataType) -> Bool {
        switch lifeTimeBehavior {
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
