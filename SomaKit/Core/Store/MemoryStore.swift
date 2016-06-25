//
//  MemoryStore.swift
//  SomaKit
//
//  Created by Anton on 25.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public class MemoryStore<TValue>: StoreType {
    public typealias KeyType = String
    public typealias DataType = TValue
    
    private var syncLock = SyncLock()
    private var dictionaryStore: [String : TValue] = [:]
    
    public func loadData(key: KeyType) throws -> DataType? {
        return syncLock.sync({ () -> DataType? in
            return dictionaryStore[key]
        })
    }
    
    public func saveData(key: KeyType, data: DataType) throws {
        return syncLock.sync({ () -> Void in
            return dictionaryStore[key] = data
        })
    }
    
    public func removeData(key: KeyType) {
        return syncLock.sync({ () -> Void in
            return dictionaryStore.removeValueForKey(key)
        })
    }
    
    public func removeAllData() {
        return syncLock.sync({ () -> Void in
            return dictionaryStore.removeAll()
        })
    }
}
