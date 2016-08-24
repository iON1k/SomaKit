//
//  ApiPartBase.swift
//  SomaKit
//
//  Created by Anton on 21.08.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import ObjectMapper
import RxSwift

public class ApiPartBase<TManager: ApiRequestManagerType> {
    private let requestManager: TManager
    
    public init(requestManager: TManager) {
        self.requestManager = requestManager
    }
    
    public final func _wrapRequest<TResponse: Mappable>(requestFactory: TManager -> ApiRequestBase<TResponse, TManager>,
        transformHandler: Observable<TResponse> -> Observable<TResponse> = SomaFunc.sameTransform) -> AnyApiRequest<TResponse> {
        return _request { manager in
            return AnyApiRequest(requestFactory(manager), transformHandler: transformHandler)
        }
    }
    
    public func _request<TRequest: RequestType where TRequest.ResponseType: Mappable>(requestFactory: TManager -> TRequest) -> TRequest {
        return requestFactory(requestManager)
    }
}
