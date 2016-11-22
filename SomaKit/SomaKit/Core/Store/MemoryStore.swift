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
    
    public func loadData(key: KeyType) -> Observable<DataType?> {
        return Observable.deferred({ () -> Observable<DataType?> in
            return Observable.just(self.beginLoadData(key: key))
        })
    }
    
    private func beginLoadData(key: KeyType) -> DataType? {
        return syncLock.sync {
            return dictionaryStore[key]
        }
    }
    
    public func storeData(key: TKey, data: DataType?) -> Observable<Void> {
        return Observable.deferred({ () -> Observable<Void> in
            return Observable.just(self.beginStoreData(key: key, data: data))
        })
    }
    
    private func beginStoreData(key: TKey, data: DataType?) {
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
