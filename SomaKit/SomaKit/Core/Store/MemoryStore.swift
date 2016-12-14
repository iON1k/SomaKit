//
//  MemoryStore.swift
//  SomaKit
//
//  Created by Anton on 25.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public class MemoryStore<TKey: Hashable, TData>: StoreType {
    public typealias KeyType = TKey
    public typealias DataType = TData
    
    private var syncLock = Sync.Lock()
    private var dictionaryStore: [KeyType : DataType] = [:]
    
    public func loadData(key: TKey) throws -> TData? {
        return syncLock.sync {
            return dictionaryStore[key]
        }
    }
    
    public func storeData(key: TKey, data: TData?) throws {
        syncLock.sync {
            guard let data = data else {
                dictionaryStore.removeValue(forKey: key)
                return
            }

            dictionaryStore[key] = data
        }
    }
    
    public func removeAllData() {
        syncLock.sync {
            return dictionaryStore.removeAll()
        }
    }
}
