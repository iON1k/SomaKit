//
//  MemoryStore.swift
//  SomaKit
//
//  Created by Anton on 25.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public class MemoryStore<TKey: StringKeyConvertiable, TData>: StoreType {
    public typealias KeyType = TKey
    public typealias DataType = TData
    
    private var syncLock = SyncLock()
    private var dictionaryStore: [String : TData] = [:]
    
    public func loadData(key: KeyType) throws -> DataType? {
        return syncLock.sync({ () -> DataType? in
            return dictionaryStore[key.asStringKey()]
        })
    }
    
    public func saveData(key: KeyType, data: DataType) throws {
        return syncLock.sync({ () -> Void in
            return dictionaryStore[key.asStringKey()] = data
        })
    }
    
    public func removeData(key: KeyType) {
        return syncLock.sync({ () -> Void in
            return dictionaryStore.removeValueForKey(key.asStringKey())
        })
    }
    
    public func removeAllData() {
        return syncLock.sync({ () -> Void in
            return dictionaryStore.removeAll()
        })
    }
}
