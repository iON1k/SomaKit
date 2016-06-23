//
//  ApiRequest.swift
//  SomaKit
//
//  Created by Anton on 16.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public enum MethodType {
    case Get
    case Post
}

public protocol ApiRequestMaganer {
    func apiRequestRunningEngine<TResponse>(request: ApiRequest<TResponse>) -> Observable<Any>
    func apiResponseMappingEngine<TResponse>(request: ApiRequest<TResponse>, sourceResponse: Any) -> Observable<TResponse>
    func apiRequestHandleError<TResponse>(request: ApiRequest<TResponse>, error: ErrorType)
}

public class ApiRequest<TResponse>: RequestType {
    public typealias ResponseType = TResponse
    public typealias ParamsType = [String : Any]
    
    private let manager: ApiRequestMaganer
    public let apiMethod: String
    public let methodType: MethodType
    public let params: ParamsType
    
    public func rxResponse() -> Observable<ResponseType> {
        return Observable.deferred({ () in
            return Observable.just(self.manager.apiRequestRunningEngine(self))
        })
        .flatMap({ (engine) -> Observable<Any> in
            return engine
        })
        .flatMap({ (response) -> Observable<ResponseType> in
            return self.manager.apiResponseMappingEngine(self, sourceResponse: response)
        })
        .doOnNext({ (response) in
            if let responseError = self._checkResponseOnError(response) {
                throw responseError
            }
        })
        .doOnError({ (error) in
            self.manager.apiRequestHandleError(self, error: error)
        })
    }
    
    public func _checkResponseOnError(response: ResponseType) -> RequestError? {
        return nil
    }
    
    public init(manager: ApiRequestMaganer, methodType: MethodType, apiMethod: String, params: ParamsType) {
        self.manager = manager
        self.methodType = methodType
        self.apiMethod = apiMethod
        self.params = params
    }
}