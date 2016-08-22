//
//  AnyApiRequest.swift
//  SomaKit
//
//  Created by Anton on 23.08.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public class AnyApiRequest<TResponse>: AnyRequest<TResponse>, StringCachingKeyProvider {
    public typealias StringCachingKeyHandler = Void -> String
    public typealias TransformHandler = Observable<TResponse> -> Observable<TResponse>
    
    private let stringCachingKeyHandler: StringCachingKeyHandler
    
    public var stringCachingKey: String {
        return stringCachingKeyHandler()
    }

    public init<TSourceRequest: protocol<RequestType, StringCachingKeyProvider>
        where TSourceRequest.ResponseType == ResponseType>(sourceRequest: TSourceRequest, transformHandler: TransformHandler = SomaFunc.sameTransform) {
        stringCachingKeyHandler = {
            sourceRequest.stringCachingKey
        }
        
        super.init {
            transformHandler(sourceRequest.response())
        }
    }
}
