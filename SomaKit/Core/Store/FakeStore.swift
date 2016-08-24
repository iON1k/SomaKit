//
//  FakeStore.swift
//  SomaKit
//
//  Created by Anton on 27.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public class FakeStore<TKey, TData>: StoreType {
    public typealias KeyType = TKey
    public typealias DataType = TData
    
    private let defaultValue: DataType?
    
    public func loadData(key: KeyType) throws -> DataType? {
        return defaultValue
    }
    
    public func saveData(key: KeyType, data: DataType?) throws {
        //Nothing
    }
    
    public init(defaultValue: DataType? = nil) {
        self.defaultValue = defaultValue
    }
}
