//
//  AnyStore.swift
//  SomaKit
//
//  Created by Anton on 25.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

open class AnyStore<TKey, TData>: StoreType {
    public typealias KeyType = TKey
    public typealias DataType = TData
    
    public typealias LoadDataHandler = (KeyType) throws -> DataType?
    public typealias SaveDataHandler = (KeyType, DataType?) throws -> Void
    
    fileprivate let loadDataHandler: LoadDataHandler
    fileprivate let saveDataHandler: SaveDataHandler
    
    open func loadData(_ key: KeyType) throws -> DataType? {
        return try loadDataHandler(key)
    }
    
    open func saveData(_ key: KeyType, data: DataType?) throws {
        try saveDataHandler(key, data)
    }
    
    public init(_ loadDataHandler: @escaping LoadDataHandler, _ saveDataHandler: @escaping SaveDataHandler) {
        self.loadDataHandler = loadDataHandler
        self.saveDataHandler = saveDataHandler
    }
}
extension AnyStore {
    public func asStore() -> AnyStore<KeyType, DataType> {
        return self
    }
}
