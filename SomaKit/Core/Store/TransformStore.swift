//
//  TransformStore.swift
//  SomaKit
//
//  Created by Anton on 25.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public class TransformStore<TKey, TData, TSourceData>: StoreType {
    public typealias KeyType = TKey
    public typealias DataType = TData
    
    public typealias TransformHandlerType = DataType throws -> TSourceData
    public typealias RevertTransformHandlerType = TSourceData throws -> DataType
    
    private let sourceStore: AnyStore<TKey, TSourceData>
    
    private let transformHandler: TransformHandlerType
    private let revertTransformHandler: RevertTransformHandlerType
    
    public func loadData(key: KeyType) throws -> DataType? {
        guard let storeData = try sourceStore.loadData(key) else {
            return nil
        }
        
        return try revertTransformHandler(storeData)
    }
    
    public func saveData(key: KeyType, data: DataType) throws {
        let storeData = try transformHandler(data)
        try sourceStore.saveData(key, data: storeData)
    }
    
    public init<TStore: StoreType where TStore.KeyType == KeyType, TStore.DataType == TSourceData>(sourceStore: TStore,
                transformHandler: TransformHandlerType, revertTransformHandler: RevertTransformHandlerType) {
        self.sourceStore = sourceStore.asAnyStore()
        self.transformHandler = transformHandler
        self.revertTransformHandler = revertTransformHandler
    }
}

extension TransformStore {
    public convenience init<TStore: StoreType, TConverter: ConverterType where TStore.KeyType == KeyType, TStore.DataType == TSourceData,
            TConverter.Type1 == DataType, TConverter.Type2 == TSourceData>(sourceStore: TStore, converter: TConverter) {
        self.init(sourceStore: sourceStore, transformHandler: converter.convertValue, revertTransformHandler: converter.convertValue)
    }
}

extension StoreType {
    public func transform<TData>(transformHandler: TData -> DataType, revertTransformHandler: DataType -> TData) -> TransformStore<KeyType, TData, DataType> {
        return TransformStore(sourceStore: self, transformHandler: transformHandler, revertTransformHandler: revertTransformHandler)
    }
    
    public func transform<TData, TConverter: ConverterType where TConverter.Type1 == TData,
            TConverter.Type2 == DataType>(converter: TConverter) -> TransformStore<KeyType, TData, DataType> {
        return TransformStore(sourceStore: self, converter: converter)
    }
}
