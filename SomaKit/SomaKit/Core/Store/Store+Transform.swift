//
//  Store+Transform.swift
//  SomaKit
//
//  Created by Anton on 25.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

extension StoreType {
    public func transform<TKey, TData>(_ transformKeyHandler: @escaping (TKey) throws -> KeyType,
                          transformDataHandler: @escaping (TData) throws -> DataType, revertTransformDataHandler: @escaping (DataType) throws -> TData) -> Store<TKey, TData> {
        
        return Store({ (key) -> Observable<TData?> in
            return Observable.deferred({ () -> Observable<TData?> in
                let sourceKey = try transformKeyHandler(key)
                return self.loadData(key: sourceKey)
                    .map({ (data) -> TData? in
                        guard let sourceData = data else {
                            return nil
                        }
                        
                        return try revertTransformDataHandler(sourceData)
                    })
            })
            }, { (key, data) -> Observable<Void> in
                return Observable.deferred({ () -> Observable<Void> in
                    let sourceKey = try transformKeyHandler(key)
                    
                    guard let data = data else {
                        return self.storeData(key: sourceKey, data: nil)
                    }
                    
                    let sourceData = try transformDataHandler(data)
                    
                    return self.storeData(key: sourceKey, data: sourceData)
                })
            })
    }
    
    public func transform<TKey, TDataConverter: ConverterType>
        (_ transformKeyHandler: @escaping (TKey) throws -> KeyType, dataConverter: TDataConverter) -> Store<TKey, TDataConverter.Type2> where TDataConverter.Type1 == DataType {
        return transform(transformKeyHandler, transformDataHandler: dataConverter.convertValue, revertTransformDataHandler: dataConverter.convertValue)
    }
    
    public func transform<TDataConverter: ConverterType>
        (_ dataConverter: TDataConverter) -> Store<KeyType, TDataConverter.Type2> where TDataConverter.Type1 == DataType {
        return transform(SomaFunc.sameTransform, transformDataHandler: dataConverter.convertValue, revertTransformDataHandler: dataConverter.convertValue)
    }
}
