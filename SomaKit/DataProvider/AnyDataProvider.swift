//
//  AnyDataProvider.swift
//  SomaKit
//
//  Created by Anton on 19.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public class AnyDataProvider<TData>: DataProviderType {
    public typealias DataType = TData
    
    private let sourceRxData: Void -> Observable<DataType>
    
    public func rxData() -> Observable<DataType> {
        return sourceRxData()
    }
    
    public init<TDataProvider: DataProviderType where TDataProvider.DataType == DataType>(dataProvider: TDataProvider) {
        sourceRxData = dataProvider.rxData
    }
}

public extension DataProviderType {
    public func asAnyProvider() -> AnyDataProvider<DataType> {
        return AnyDataProvider(dataProvider: self)
    }
}