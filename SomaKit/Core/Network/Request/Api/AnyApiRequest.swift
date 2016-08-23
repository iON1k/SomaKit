//
//  AnyApiRequest.swift
//  SomaKit
//
//  Created by Anton on 23.08.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public class AnyApiRequest<TResponse>: AnyRequest<TResponse>, CachingKeyProvider {
    public typealias CachingKeyType = String
    public typealias CachingKeyHandler = Void -> CachingKeyType
    public typealias TransformHandler = Observable<TResponse> -> Observable<TResponse>
    
    private let cachingKeyHandler: CachingKeyHandler
    
    public var cachingKey: CachingKeyType {
        return cachingKeyHandler()
    }

    public init<TSourceRequest: protocol<RequestType, CachingKeyProvider> where TSourceRequest.ResponseType == ResponseType,
        TSourceRequest.CachingKeyType == CachingKeyType>(sourceRequest: TSourceRequest, transformHandler: TransformHandler = SomaFunc.sameTransform) {
        cachingKeyHandler = {
            return sourceRequest.cachingKey
        }
        
        super.init {
            transformHandler(sourceRequest.response())
        }
    }
}
