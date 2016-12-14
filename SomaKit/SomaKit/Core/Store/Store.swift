//
//  Store.swift
//  SomaKit
//
//  Created by Anton on 05.11.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public class Store<TKey, TData>: StoreType {
    public typealias KeyType = TKey
    public typealias DataType = TData
    
    public typealias LoadDataHandler = (KeyType) throws -> TData?
    public typealias SaveDataHandler = (KeyType, DataType?) throws -> Void
    
    private let loadDataHandler: LoadDataHandler
    private let saveDataHandler: SaveDataHandler
    
    public func loadData(key: TKey) throws -> TData? {
        return try loadDataHandler(key)
    }
    
    public func storeData(key: TKey, data: TData?) throws {
        return try saveDataHandler(key, data)
    }
    
    public init(_ loadDataHandler: @escaping LoadDataHandler, _ saveDataHandler: @escaping SaveDataHandler) {
        self.loadDataHandler = loadDataHandler
        self.saveDataHandler = saveDataHandler
    }
}

extension Store {
    public func asStore() -> Store<KeyType, DataType> {
        return self
    }
}
