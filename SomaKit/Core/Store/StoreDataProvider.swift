//
//  StoreDataProvider.swift
//  SomaKit
//
//  Created by Anton on 23.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public class StoreDataProvider<TData, TKey>: DataProviderType {
    public typealias DataType = TData
    public typealias KeyType = TKey
    
    private let dataValue: Variable<DataType>
    
    private let store: AnyStore<KeyType, DataType>
    
    private let key: KeyType
    private let defaultValue: DataType
    
    public func rxData() -> Observable<DataType> {
        return dataValue.asObservable()
    }
    
    public init<TStore: StoreConvertibleType where TStore.DataType == DataType, TStore.KeyType == KeyType>(store: TStore, key: KeyType, defaultValue: DataType) {
        self.store = store.asAnyStore()
        
        self.key = key
        self.defaultValue = defaultValue
        
        dataValue = Variable(defaultValue)
    }
    
    public func setData(data: DataType) throws {
        try store.saveData(key, data: data)
        dataValue.value = data
    }
    
    public func loadData() throws -> DataType {
        let data = normalizeData(try store.loadData(key))
        dataValue.value = data
        return data
    }
    
    public func setDataSafe(data: DataType) {
        do {
            try setData(data)
        } catch let error {
            Log.log(error)
        }
    }
    
    public func loadDataSafe() -> DataType {
        do {
            return try loadData()
        } catch let error {
            Log.log(error)
        }
        
        return defaultValue
    }
    
    private func normalizeData(data: DataType?) -> DataType {
        if let data = data {
            return data
        } else {
            return self.defaultValue
        }
    }
}

extension StoreDataProvider where TData: DefaultValueType {
    public convenience init<TStore: StoreType where TStore.DataType == DataType, TStore.KeyType == KeyType>(store: TStore, key: KeyType) {
        self.init(store: store, key: key, defaultValue: TData.defaultValue)
    }
}