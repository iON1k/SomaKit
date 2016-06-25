//
//  StoreDataProvider.swift
//  SomaKit
//
//  Created by Anton on 23.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public class StoreDataProvider<TData, TStore: StoreType>: DataProviderType {
    
    public typealias DataType = TData
    public typealias StoreDataType = TStore.DataType
    public typealias StoreKeyType = TStore.KeyType
    
    private let dataValue: Variable<DataType>
    private let store: TStore
    private let key: StoreKeyType
    private let converter: AnyConverter<DataType, StoreDataType>
    
    public func rxData() -> Observable<DataType> {
        return dataValue.asObservable()
    }
    
    public init<TConverter: ConverterType where TConverter.Type1 == DataType,
        TConverter.Type2 == StoreDataType>(store: TStore, key: StoreKeyType, converter: TConverter, defaultValue: DataType) {
        self.store = store
        self.key = key
        self.converter = converter.asAny()
        dataValue = Variable(defaultValue)
    }
    
    public func setData(data: DataType) throws {
        let storeData = try converter.convertValue(data)
        try store.saveData(key, data: storeData)
        dataValue.value = data
    }
    
    public func loadData() throws -> DataType? {
        guard let storeData = try store.loadData(key) else {
            return nil
        }
        
        let data = try converter.convertValue(storeData)
        dataValue.value = data
        return data
    }
}

public extension StoreDataProvider where TData == TStore.DataType {
    public convenience init(store: TStore, key: StoreKeyType, defaultValue: DataType) {
        self.init(store: store, key: key, converter: SameTypeConverter(), defaultValue: defaultValue)
    }
}