//
//  AnyDataLoader.swift
//  SomaKit
//
//  Created by Anton on 22.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public class AnyDataLoader<TData>: AnyDataProvider<TData>, DataLoaderType {
    private let sourceLoadData: Void -> Observable<DataType>
    
    public func loadData() -> Observable<DataType> {
        return sourceLoadData()
    }
    
    public init<TDataLoader: DataLoaderType where TDataLoader.DataType == DataType>(dataLoader: TDataLoader) {
        sourceLoadData = dataLoader.loadData
        super.init(dataProvider: dataLoader)
    }
}

public extension DataLoaderType {
    public func asAnyLoader() -> AnyDataLoader<DataType> {
        return AnyDataLoader(dataLoader: self)
    }
}