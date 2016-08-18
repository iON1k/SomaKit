//
//  DataProviderType.swift
//  SomaKit
//
//  Created by Anton on 13.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public protocol DataProviderType: ObservableConvertibleType, DataProviderConvertibleType {
    associatedtype DataType
    func dataObservable() -> Observable<DataType>
}

extension DataProviderType {
    public typealias E = DataType
    
    public func asObservable() -> Observable<DataType> {
        return Observable.deferred({ () -> Observable<DataType> in
            return self.dataObservable()
        })
    }
}

extension DataProviderType {
    public func asAnyDataProvider() -> AnyDataProvider<DataType> {
        return AnyDataProvider(dataObservable)
    }
}