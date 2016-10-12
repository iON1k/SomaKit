//
//  StoreType.swift
//  SomaKit
//
//  Created by Anton on 23.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public protocol StoreType: StoreConvertibleType {
    associatedtype KeyType
    associatedtype DataType
    
    func loadData(_ key: KeyType) throws -> DataType?
    func saveData(_ key: KeyType, data: DataType?) throws
}

extension StoreType {
    public func asStore() -> AnyStore<KeyType, DataType> {
        return AnyStore(loadData, saveData)
    }
}

extension StoreType {
    public func loadDataSafe(_ key: KeyType) -> DataType? {
        return Utils.safe {
            return try self.loadData(key)
        }
    }
    
    public func saveDataSafe(_ key: KeyType, data: DataType?) {
        Utils.safe {
            try self.saveData(key, data: data)
        }
    }
    
    public func removeData(_ key: KeyType) throws {
        try saveData(key, data: nil)
    }
    
    public func removeDataSafe(_ key: KeyType) throws {
        Utils.safe {
            try self.saveData(key, data: nil)
        }
    }
}
