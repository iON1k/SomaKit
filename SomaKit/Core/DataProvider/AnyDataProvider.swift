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
    public typealias DataHandlerType = Void -> Observable<DataType>
    
    private let sourceDataHandler: DataHandlerType
    
    public func dataObservable() -> Observable<DataType> {
        return sourceDataHandler()
    }
    
    public init(_ sourceDataHandler: DataHandlerType) {
        self.sourceDataHandler = sourceDataHandler
    }
}

public extension AnyDataProvider {
    public func asAnyDataProvider() -> AnyDataProvider<DataType> {
        return self
    }
}