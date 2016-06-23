//
//  AnyRequest.swift
//  SomaKit
//
//  Created by Anton on 15.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public class AnyRequest<TResponse>: RequestType {
    public typealias ResponseType = TResponse

    private let sourceRxResponse: Void -> Observable<ResponseType>
    
    public func rxResponse() -> Observable<ResponseType> {
        return sourceRxResponse()
    }
    
    public init<TRequest: RequestType where TRequest.ResponseType == ResponseType>(sourceRequest: TRequest) {
        sourceRxResponse = sourceRequest.rxResponse
    }
}

public extension RequestType {
    public func asAny() -> AnyRequest<ResponseType> {
        return AnyRequest(sourceRequest: self)
    }
}