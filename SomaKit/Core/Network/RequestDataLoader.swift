//
//  RequestDataLoader.swift
//  SomaKit
//
//  Created by Anton on 22.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public class RequestDataLoader<TRequest: RequestType, TData>: DataProviderType {
    public typealias DataType = TData
    public typealias TransformHandler = TRequest.ResponseType -> DataType
    
    private let dataValue = Variable<DataType?>(nil)
    
    private let request: TRequest
    private let transformHandler: TransformHandler
    
    public func rxData() -> Observable<DataType> {
        return dataValue.asObservable()
            .ignoreNil()
    }
    
    public func loadData() -> Observable<DataType> {
        return request.rxResponse()
            .map { (response) -> DataType in
                return self.transformHandler(response)
            }
            .doOnNext { (newData) in
                self.dataValue.value = newData
            }
    }
    
    public init(request: TRequest, transformHandler: TransformHandler) {
        self.request = request
        self.transformHandler = transformHandler
    }
}

public extension RequestType {
    public func asDataLoader<TData>(transformHandler: ResponseType -> TData) -> RequestDataLoader<Self, TData> {
        return RequestDataLoader(request: self, transformHandler: transformHandler)
    }
    
    public func asDataLoader() -> RequestDataLoader<Self, ResponseType> {
        return asDataLoader(SomaFunc.emptyTransform)
    }
}