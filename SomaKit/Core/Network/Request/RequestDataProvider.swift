//
//  RequestDataProvider.swift
//  SomaKit
//
//  Created by Anton on 21.08.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public class RequestDataProvider<TResponse>: AnyDataProvider<TResponse> {
    public init<TRequest: RequestType, TRequestManager where TRequest.ManagerType == TRequestManager,
        TRequest.ResponseType == TResponse>(request: TRequest, manager: TRequestManager) {
        super.init { () -> Observable<TResponse> in
            return request.execute(manager)
        }
    }
}

public class CachingRequestDataProvider<TResponse>: RequestDataProvider<TResponse>, CachingKeyProvider {
    public typealias CachingKeyHandlerType = Void -> String
    
    private let cachingKeyHandler: CachingKeyHandlerType
    
    public var cachingKey: String {
        return cachingKeyHandler()
    }
    
    public init<TRequest: RequestType where TRequest: CachingKeyProvider,
        TRequest.ResponseType == TResponse>(request: TRequest, manager: TRequest.ManagerType) {
        cachingKeyHandler = {
            return request.cachingKey
        }
        
        super.init(request: request, manager: manager)
    }
}