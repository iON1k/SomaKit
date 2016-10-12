//
//  MemoryStore.swift
//  SomaKit
//
//  Created by Anton on 25.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

open class MemoryStore<TKey: Hashable, TData>: StoreType {
    public typealias KeyType = TKey
    public typealias DataType = TData
    
    fileprivate var syncLock = SyncLock()
    fileprivate var dictionaryStore: [TKey : TData] = [:]
    
    open func loadData(_ key: KeyType) throws -> DataType? {
        return syncLock.sync {
            return dictionaryStore[key]
        }
    }
    
    open func saveData(_ key: KeyType, data: DataType?) throws {
        return syncLock.sync {
            guard let data = data else {
                dictionaryStore.removeValue(forKey: key)
                return
            }
            
            return dictionaryStore[key] = data
        }
    }
    
    open func removeData(_ key: KeyType) {
        return syncLock.sync {
            return dictionaryStore.removeValue(forKey: key)
        }
    }
    
    open func removeAllData() {
        return syncLock.sync {
            return dictionaryStore.removeAll()
        }
    }
}
