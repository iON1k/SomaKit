//
//  AnyDataProvider.swift
//  SomaKit
//
//  Created by Anton on 19.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public class AnyDataProvider<TData>: TransformDataProvider<TData, TData> {
    public init<TDataSource: DataProviderConvertibleType where TDataSource.DataType == DataType>(dataSource: TDataSource) {
        super.init(dataSource: dataSource, transformHandler: SomaFunc.emptyTransform)
    }
}

public extension DataProviderConvertibleType {
    public func asAny() -> AnyDataProvider<DataType> {
        return AnyDataProvider(dataSource: self)
    }
}