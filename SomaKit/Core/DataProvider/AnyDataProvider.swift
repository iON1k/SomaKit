//
//  AnyDataProvider.swift
//  SomaKit
//
//  Created by Anton on 19.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public class AnyDataProvider<TData>: TransformDataProvider<TData, TData> {
    public init<TDataProvider: DataProviderType where TDataProvider.DataType == DataType>(dataProvider: TDataProvider) {
        super.init(dataProvider: dataProvider, transformHandler: SomaFunc.emptyTransform)
    }
}

public extension DataProviderType {
    public func asAnyProvider() -> AnyDataProvider<DataType> {
        return AnyDataProvider(dataProvider: self)
    }
}