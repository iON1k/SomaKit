//
//  ApiClientBase.swift
//  SomaKit
//
//  Created by Anton on 21.08.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public class _ApiClientBase<TManager: RequestManagerType> {
    public typealias ManagerType = TManager
    
    public let _requestManager: ManagerType
    
    public init(requestManager: ManagerType) {
        self._requestManager = requestManager
    }
}

public class ApiClientBase<TManager: RequestManagerType>: _ApiClientBase<TManager> {
    public func _wrap<TRequest: RequestType where TRequest.ManagerType == ManagerType>(request: TRequest) -> RequestDataProvider<TRequest.ResponseType> {
        return RequestDataProvider(request: request, manager: _requestManager)
    }
    
    public func _wrap<TRequest: RequestType where TRequest: CachingKeyProvider,
        TRequest.ManagerType == ManagerType>(request: TRequest) -> CachingRequestDataProvider<TRequest.ResponseType> {
        return CachingRequestDataProvider(request: request, manager: _requestManager)
    }
}
