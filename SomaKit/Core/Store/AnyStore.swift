//
//  AnyStore.swift
//  SomaKit
//
//  Created by Anton on 25.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public class AnyStore<TKey, TData>: StoreType {
    public typealias KeyType = TKey
    public typealias DataType = TData
    
    public typealias LoadDataHandler = KeyType throws -> DataType?
    public typealias SaveDataHandler = (KeyType, DataType) throws -> Void
    
    private let loadDataHandler: LoadDataHandler
    private let saveDataHandler: SaveDataHandler
    
    public func loadData(key: KeyType) throws -> DataType? {
        return try loadDataHandler(key)
    }
    
    public func saveData(key: KeyType, data: DataType) throws {
        try saveDataHandler(key, data)
    }
    
    public init(_ loadDataHandler: LoadDataHandler, _ saveDataHandler: SaveDataHandler) {
        self.loadDataHandler = loadDataHandler
        self.saveDataHandler = saveDataHandler
    }
}
extension AnyStore {
    public func asStore() -> AnyStore<KeyType, DataType> {
        return self
    }
}