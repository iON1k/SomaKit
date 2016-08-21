//
//  TransformDataProvider.swift
//  SomaKit
//
//  Created by Anton on 23.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public class TransformDataProvider<TData, TSourceData>: DataProviderType {
    public typealias DataType = TData
    public typealias TransformHandler = Observable<TSourceData> -> Observable<DataType>
    
    private let sourceDataProvider: AnyDataProvider<TSourceData>
    private let transformHandler: TransformHandler
    
    public func data() -> Observable<DataType> {
        return transformHandler(sourceDataProvider.data())
    }
    
    public init<TDataProvider: DataProviderConvertibleType where TDataProvider.DataType == TSourceData>(dataProvider: TDataProvider, transformHandler: TransformHandler) {
        sourceDataProvider = dataProvider.asAnyDataProvider()
        self.transformHandler = transformHandler
    }
}

extension DataProviderConvertibleType {
    public func transform<TData>(transformHandler: Observable<DataType> -> Observable<TData>) -> TransformDataProvider<TData, DataType> {
        return TransformDataProvider(dataProvider: self, transformHandler: transformHandler)
    }
}