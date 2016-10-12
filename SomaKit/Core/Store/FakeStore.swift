//
//  FakeStore.swift
//  SomaKit
//
//  Created by Anton on 27.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

open class FakeStore<TKey, TData>: StoreType {
    public typealias KeyType = TKey
    public typealias DataType = TData
    
    fileprivate let defaultValue: DataType?
    
    open func loadData(_ key: KeyType) throws -> DataType? {
        return defaultValue
    }
    
    open func saveData(_ key: KeyType, data: DataType?) throws {
        //Nothing
    }
    
    public init(defaultValue: DataType? = nil) {
        self.defaultValue = defaultValue
    }
}
