//
//  DataLoader.swift
//  SomaKit
//
//  Created by Anton on 25.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public class DataLoader<TData>: DataProviderType {
    public typealias DataType = TData
    public typealias SourceDataHandler = Void -> Observable<DataType>
    
    private let dataValue: Variable<DataType>
    
    private let sourceProvider: AnyDataProvider<TData>
    private let defaultValue: DataType
    
    public func dataObservable() -> Observable<DataType> {
        return dataValue.asObservable()
    }
    
    public var data: DataType {
        return dataValue.value
    }
    
    public func fetchData() -> Observable<DataType> {
        return sourceProvider.dataObservable()
            .doOnNext { (data) in
                self.dataValue <= data
            }
    }
    
    public init<TDataProvider: DataProviderConvertibleType where TDataProvider.DataType == DataType>(dataProvider: TDataProvider, defaultValue: DataType) {
        self.sourceProvider = dataProvider.asAnyDataProvider()
        self.defaultValue = defaultValue
        
        dataValue = Variable(defaultValue)
    }
}

public extension DataProviderConvertibleType {
    public func asDataLoader(defaultValue: DataType) -> DataLoader<DataType> {
        return DataLoader(dataProvider: self, defaultValue: defaultValue)
    }
}

public extension DataProviderConvertibleType where DataType: DefaultValueType {
    public func asDataLoader() -> DataLoader<DataType> {
        return asDataLoader(DataType.defaultValue)
    }
}
