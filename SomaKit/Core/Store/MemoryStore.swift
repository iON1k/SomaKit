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
    
    private var dictionaryStore: [String : TValue] = [:]
    
    public func loadData(key: KeyType) throws -> DataType? {
        return dictionaryStore[key]
    }
    
    public func saveData(key: KeyType, data: DataType) throws {
        dictionaryStore[key] = data
    }
}
