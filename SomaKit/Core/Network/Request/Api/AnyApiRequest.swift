//
//  AnyApiRequest.swift
//  SomaKit
//
//  Created by Anton on 23.08.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public class AnyApiRequest<TResponse>: RequestType, StringCachingKeyProvider {
    public typealias ResponseType = TResponse
    public typealias StringCachingKeyHandler = Void -> String
    public typealias TransformHandler = Observable<TResponse> -> Observable<TResponse>
    public typealias ResponseHandlerType = Void -> Observable<ResponseType>
    
    private let responseHandler: ResponseHandlerType
    
    private let stringCachingKeyHandler: StringCachingKeyHandler
    
    public var stringCachingKey: String {
        return stringCachingKeyHandler()
    }
    
    public func response() -> Observable<ResponseType> {
        return responseHandler()
    }

    public init<TSourceRequest: protocol<RequestType, StringCachingKeyProvider>
        where TSourceRequest.ResponseType == ResponseType>(_ sourceRequest: TSourceRequest, transformHandler: TransformHandler = SomaFunc.sameTransform) {
        responseHandler = {
            transformHandler(sourceRequest.response())
        }
        stringCachingKeyHandler = {
            return sourceRequest.stringCachingKey
        }
    }
}