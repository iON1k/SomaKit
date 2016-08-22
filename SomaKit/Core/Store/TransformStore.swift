//
//  TransformStore.swift
//  SomaKit
//
//  Created by Anton on 25.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public class TransformStore<TKey, TSourceKey, TData, TSourceData>: StoreType {
    public typealias KeyType = TKey
    public typealias DataType = TData
    
    public typealias TransformKeyHandlerType = TKey throws -> TSourceKey
    public typealias RevertTransformKeyHandlerType = TSourceKey throws -> TKey
    
    public typealias TransformDataHandlerType = DataType throws -> TSourceData
    public typealias RevertTransformDataHandlerType = TSourceData throws -> DataType
    
    private let sourceStore: AnyStore<TSourceKey, TSourceData>
    
    private let transformKeyHandler: TransformKeyHandlerType
    private let revertTransformKeyHandler: RevertTransformKeyHandlerType
    
    private let transformDataHandler: TransformDataHandlerType
    private let revertTransformDataHandler: RevertTransformDataHandlerType
    
    public func loadData(key: KeyType) throws -> DataType? {
        let storeKey = try transformKeyHandler(key)
        guard let storeData = try sourceStore.loadData(storeKey) else {
            return nil
        }
        
        return try revertTransformDataHandler(storeData)
    }
    
    public func saveData(key: KeyType, data: DataType) throws {
        let storeKey = try transformKeyHandler(key)
        let storeData = try transformDataHandler(data)
        try sourceStore.saveData(storeKey, data: storeData)
    }
    
    public init<TStore: StoreType where TStore.KeyType == TSourceKey, TStore.DataType == TSourceData>(sourceStore: TStore,
                transformKeyHandler: TransformKeyHandlerType, revertTransformKeyHandler: RevertTransformKeyHandlerType,
                transformDataHandler: TransformDataHandlerType, revertTransformDataHandler: RevertTransformDataHandlerType) {
        self.sourceStore = sourceStore.asStore()
        
        self.transformDataHandler = transformDataHandler
        self.revertTransformDataHandler = revertTransformDataHandler
        
        self.transformKeyHandler = transformKeyHandler
        self.revertTransformKeyHandler = revertTransformKeyHandler
    }
}

extension TransformStore {
    public convenience init<TStore: StoreType, TKeyConverter: ConverterType, TDataConverter: ConverterType
        where TStore.KeyType == TSourceKey, TStore.DataType == TSourceData, TKeyConverter.Type1 == KeyType, TKeyConverter.Type2 == TSourceKey,
        TDataConverter.Type1 == DataType, TDataConverter.Type2 == TSourceData>(sourceStore: TStore, keyConverter: TKeyConverter, dataConverter: TDataConverter) {
        
        self.init(sourceStore: sourceStore, transformKeyHandler: keyConverter.convertValue, revertTransformKeyHandler: keyConverter.convertValue,
                  transformDataHandler: dataConverter.convertValue, revertTransformDataHandler: dataConverter.convertValue)
    }
}

extension StoreType {
    public func transform<TKey, TData>(transformKeyHandler: TKey -> KeyType, revertTransformKeyHandler: KeyType -> TKey, transformDataHandler: TData -> DataType, revertTransformDataHandler: DataType -> TData) -> TransformStore<TKey, KeyType, TData, DataType> {
        
        return TransformStore(sourceStore: self, transformKeyHandler: transformKeyHandler, revertTransformKeyHandler: revertTransformKeyHandler,
                              transformDataHandler: transformDataHandler, revertTransformDataHandler: revertTransformDataHandler)
    }
    
    public func transform<TKey, TData, TKeyConverter: ConverterType, TDataConverter: ConverterType
        where TKeyConverter.Type1 == TKey, TKeyConverter.Type2 == KeyType, TDataConverter.Type1 == TData,
            TDataConverter.Type2 == DataType>(keyConverter: TKeyConverter, dataConverter: TDataConverter) -> TransformStore<TKey, KeyType, TData, DataType> {
        
        return TransformStore(sourceStore: self, keyConverter: keyConverter, dataConverter: dataConverter)
    }
}
