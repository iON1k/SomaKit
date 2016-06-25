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
    
    private let sourceDataHandler: SourceDataHandler
    private let defaultValue: DataType
    
    public func rxData() -> Observable<DataType> {
        return dataValue.asObservable()
    }
    
    public var data: DataType {
        return dataValue.value
    }
    
    public func fetchData() -> Observable<DataType> {
        return sourceDataHandler()
            .doOnNext { (data) in
                self.dataValue.value = data
            }
    }
    
    public init<TDataSource: DataProviderConvertibleType where TDataSource.DataType == DataType>(dataSource: TDataSource, defaultValue: DataType) {
        self.sourceDataHandler = dataSource.asDataProvider().rxData
        self.defaultValue = defaultValue
        
        dataValue = Variable(defaultValue)
    }
}

public extension DataProviderType {
    public func asDataLoader(defaultValue: DataType) -> DataLoader<DataType> {
        return DataLoader(dataSource: self, defaultValue: defaultValue)
    }
}

public extension DataProviderType where DataType: DefaultValueType {
    public func asDataLoader() -> DataLoader<DataType> {
        return asDataLoader(DataType.defaultValue)
    }
}
