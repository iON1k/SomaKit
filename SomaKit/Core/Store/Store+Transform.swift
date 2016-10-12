//
//  Store+Transform.swift
//  SomaKit
//
//  Created by Anton on 25.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

extension StoreType {
    public func transform<TKey, TData>(_ transformKeyHandler: @escaping (TKey) throws -> KeyType,
                          transformDataHandler: @escaping (TData) throws -> DataType, revertTransformDataHandler: @escaping (DataType) throws -> TData) -> AnyStore<TKey, TData> {
        
        return AnyStore({ (key) -> TData? in
            let sourceKey = try transformKeyHandler(key)
            guard let sourceData = try self.loadData(sourceKey) else {
                return nil
            }
            
            return try revertTransformDataHandler(sourceData)
            }, { (key, data) in
                let sourceKey = try transformKeyHandler(key)
                guard let data = data else {
                    try self.saveData(sourceKey, data: nil)
                    return
                }
                
                let sourceData = try transformDataHandler(data)
                
                try self.saveData(sourceKey, data: sourceData)
            })
    }
    
    public func transform<TKey, TDataConverter: ConverterType>
        (_ transformKeyHandler: @escaping (TKey) throws -> KeyType, dataConverter: TDataConverter) -> AnyStore<TKey, TDataConverter.Type2> where TDataConverter.Type1 == DataType {
        return transform(transformKeyHandler, transformDataHandler: dataConverter.convertValue, revertTransformDataHandler: dataConverter.convertValue)
    }
    
    public func transform<TDataConverter: ConverterType>
        (_ dataConverter: TDataConverter) -> AnyStore<KeyType, TDataConverter.Type2> where TDataConverter.Type1 == DataType {
        return transform(SomaFunc.sameTransform, transformDataHandler: dataConverter.convertValue, revertTransformDataHandler: dataConverter.convertValue)
    }
}
