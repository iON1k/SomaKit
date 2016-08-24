//
//  MemoryStore.swift
//  SomaKit
//
//  Created by Anton on 25.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public class MemoryStore<TKey: Hashable, TData>: StoreType {
    public typealias KeyType = TKey
    public typealias DataType = TData
    
    private var syncLock = SyncLock()
    private var dictionaryStore: [TKey : TData] = [:]
    
    public func loadData(key: KeyType) throws -> DataType? {
        return syncLock.sync {
            return dictionaryStore[key]
        }
    }
    
    public func saveData(key: KeyType, data: DataType?) throws {
        return syncLock.sync {
            guard let data = data else {
                dictionaryStore.removeValueForKey(key)
                return
            }
            
            return dictionaryStore[key] = data
        }
    }
    
    public func removeData(key: KeyType) {
        return syncLock.sync {
            return dictionaryStore.removeValueForKey(key)
        }
    }
    
    public func removeAllData() {
        return syncLock.sync {
            return dictionaryStore.removeAll()
        }
    }
}
