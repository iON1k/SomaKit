//
//  StoreDataProvider.swift
//  SomaKit
//
//  Created by Anton on 23.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public class StoreDataProvider<TDataConverter: ConverterType, TStore: StoreType
    where TDataConverter.ToValueType == TStore.DataType>: DataProviderType {
    
    public typealias DataType = TDataConverter.FromValueType
    public typealias StoreDataType = TStore.DataType
    public typealias StoreKeyType = TStore.KeyType
    
    private let dataValue: Variable<DataType>
    private let store: TStore
    private let key: StoreKeyType
    private let converter: TDataConverter
    
    public func rxData() -> Observable<DataType> {
        return dataValue.asObservable()
    }
    
    public init(store: TStore, key: StoreKeyType, converter: TDataConverter, defaultValue: DataType) {
        self.store = store
        self.key = key
        self.converter = converter
        dataValue = Variable(defaultValue)
    }
    
    public func setData(data: DataType) throws {
        let storeData = try converter.convertValue(data)
        try store.saveData(key, data: storeData)
        dataValue.value = data
    }
    
    public func loadData() throws -> DataType {
        let storeData = try store.loadData(key)
        let data = try converter.convertValue(storeData)
        dataValue.value = data
        return data
    }
}