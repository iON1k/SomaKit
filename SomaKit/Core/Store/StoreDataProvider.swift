//
//  StoreDataProvider.swift
//  SomaKit
//
//  Created by Anton on 23.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

open class StoreDataProvider<TData, TKey>: DataProviderType {
    public typealias DataType = TData
    public typealias KeyType = TKey
    
    private let dataValue: Variable<DataType>
    
    private let store: AnyStore<KeyType, DataType>
    
    private let key: KeyType
    private let defaultValue: DataType
    
    open func data() -> Observable<DataType> {
        return dataValue.asObservable()
    }
    
    public init<TStore: StoreConvertibleType>(store: TStore, key: KeyType, defaultValue: DataType) where TStore.DataType == DataType, TStore.KeyType == KeyType {
        self.store = store.asStore()
        
        self.key = key
        self.defaultValue = defaultValue
        
        dataValue = Variable(defaultValue)
    }
    
    open func setData(_ data: DataType?) throws {
        try store.saveData(key, data: data)
        dataValue <= data ?? defaultValue
    }
    
    open func loadData() throws -> DataType {
        let data = normalizeData(try store.loadData(key))
        dataValue <= data
        return data
    }
    
    open func setDataSafe(_ data: DataType?) {
        Utils.safe {
            try self.setData(data)
        }
    }
    
    open func loadDataSafe() -> DataType {
        return Utils.safe(defaultValue) {
            return try self.loadData()
        }
    }
    
    private func normalizeData(_ data: DataType?) -> DataType {
        if let data = data {
            return data
        } else {
            return self.defaultValue
        }
    }
}

extension StoreDataProvider where TData: DefaultValueType {
    public convenience init<TStore: StoreType>(store: TStore, key: KeyType) where TStore.DataType == DataType, TStore.KeyType == KeyType {
        self.init(store: store, key: key, defaultValue: TData.defaultValue)
    }
}
