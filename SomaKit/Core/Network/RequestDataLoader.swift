//
//  RequestDataLoader.swift
//  SomaKit
//
//  Created by Anton on 22.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

private enum RequestDataLoaderValue<TData> {
    case NoData
    case SomeData(data: TData)
}

public class RequestDataLoader<TRequest: RequestType, TData>: DataLoaderType {
    public typealias DataType = TData
    public typealias TransformHandler = TRequest.ResponseType -> DataType
    
    
    private let dataValue = Variable<RequestDataLoaderValue<DataType>>(.NoData)
    
    private let request: TRequest
    private let transformHandler: TransformHandler
    
    public func rxData() -> Observable<DataType> {
        return dataValue.asObservable()
            .flatMap({ (dataValue) -> Observable<DataType> in
                switch dataValue {
                case .NoData:
                    return Observable.empty()
                case .SomeData(let data):
                    return Observable.just(data)
                }
            })
    }
    
    public func loadData() -> Observable<DataType> {
        return request.rxResponse()
            .map { (response) -> DataType in
                return self.transformHandler(response)
            }
            .doOnNext { (newData) in
                self.dataValue.value = RequestDataLoaderValue.SomeData(data: newData)
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