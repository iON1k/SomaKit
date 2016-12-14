//
//  StoreType.swift
//  SomaKit
//
//  Created by Anton on 23.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public protocol StoreType {
    associatedtype KeyType
    associatedtype DataType
    
    func loadData(key: KeyType) throws -> DataType?
    func storeData(key: KeyType, data: DataType?) throws
    
    func asStore() -> Store<KeyType, DataType>
}

extension StoreType {
    public func asStore() -> Store<KeyType, DataType> {
        return Store(loadData, storeData)
    }
}

public extension StoreType {
    public func loadDataSafe(key: KeyType) -> DataType? {
        return Utils.safe {
            return try loadData(key: key)
        }
    }

    public func storeDataSafe(key: KeyType, data: DataType?) {
        Utils.safe {
            try storeData(key: key, data: data)
        }
    }
}
