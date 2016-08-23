//
//  Store+Transform.swift
//  SomaKit
//
//  Created by Anton on 25.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

extension StoreType {
    public func transform<TKey, TData>(transformKeyHandler: TKey throws -> KeyType,
                          transformDataHandler: TData throws -> DataType, revertTransformDataHandler: DataType throws -> TData) -> AnyStore<TKey, TData> {
        
        return AnyStore({ (key) -> TData? in
            let sourceKey = try transformKeyHandler(key)
            guard let sourceData = try self.loadData(sourceKey) else {
                return nil
            }
            
            return try revertTransformDataHandler(sourceData)
            }, { (key, data) in
                let sourceKey = try transformKeyHandler(key)
                let sourceData = try transformDataHandler(data)
                
                try self.saveData(sourceKey, data: sourceData)
            })
    }
    
    public func transform<TKey, TDataConverter: ConverterType where TDataConverter.Type1 == DataType>
        (transformKeyHandler: TKey throws -> KeyType, dataConverter: TDataConverter) -> AnyStore<TKey, TDataConverter.Type2> {
        return transform(transformKeyHandler, transformDataHandler: dataConverter.convertValue, revertTransformDataHandler: dataConverter.convertValue)
    }
    
    public func transform<TDataConverter: ConverterType where TDataConverter.Type1 == DataType>
        (dataConverter: TDataConverter) -> AnyStore<KeyType, TDataConverter.Type2> {
        return transform(SomaFunc.sameTransform, transformDataHandler: dataConverter.convertValue, revertTransformDataHandler: dataConverter.convertValue)
    }
}
