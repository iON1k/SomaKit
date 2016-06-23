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
    
    private let sourceRxData: Void -> Observable<TSourceData>
    private let transformHandler: TransformHandler
    
    public func rxData() -> Observable<DataType> {
        return transformHandler(sourceRxData())
    }
    
    public init<TDataProvider: DataProviderType where TDataProvider.DataType == TSourceData>(dataProvider: TDataProvider, transformHandler: TransformHandler) {
        sourceRxData = dataProvider.rxData
        self.transformHandler = transformHandler
    }
}

extension DataProviderType {
    public func transform<TData>(transformHandler: Observable<DataType> -> Observable<TData>) -> TransformDataProvider<TData, DataType> {
        return TransformDataProvider(dataProvider: self, transformHandler: transformHandler)
    }
}