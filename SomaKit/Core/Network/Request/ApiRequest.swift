//
//  ApiRequest.swift
//  SomaKit
//
//  Created by Anton on 16.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public enum ApiMethodType: String {
    case Get
    case Post
}

public protocol ApiRequestMaganer {
    func apiRequestRunningEngine<TResponse>(request: ApiRequest<TResponse>) throws -> Observable<Any>
    func apiResponseMappingEngine<TResponse>(request: ApiRequest<TResponse>, sourceResponse: Any) -> Observable<TResponse>
    func apiRequestHandleError<TResponse>(request: ApiRequest<TResponse>, error: ErrorType)
    func apiRequestCompleted<TResponse>(request: ApiRequest<TResponse>, response: TResponse)
}

public class ApiRequest<TResponse>: RequestType, StringCachingKeyProvider {
    public typealias ResponseType = TResponse
    public typealias ParamsType = [String : StringKeyConvertiable]?
    public typealias HeadersType = [String : String]?
    
    private let manager: ApiRequestMaganer
    public let apiMethod: String
    public let methodType: ApiMethodType
    public let params: ParamsType
    public let headers: HeadersType
    
    private let stringCachingKeyCache = LazyCachingValue<String>()
    
    public var stringCachingKey: String {
        return stringCachingKeyCache.value
    }
    
    public func rxResponse() -> Observable<ResponseType> {
        return Observable.deferred({ () in
            return try Observable.just(self.manager.apiRequestRunningEngine(self))
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
            
            self.manager.apiRequestCompleted(self, response: response)
        })
        .doOnError({ (error) in
            self.manager.apiRequestHandleError(self, error: error)
        })
    }
    
    public func _checkResponseOnError(response: ResponseType) -> RequestError? {
        return nil
    }
    
    public init(manager: ApiRequestMaganer, methodType: ApiMethodType, apiMethod: String,
                params: ParamsType = nil, headers: HeadersType = nil) {
        self.manager = manager
        self.methodType = methodType
        self.apiMethod = apiMethod
        self.params = params
        self.headers = headers
        
        stringCachingKeyCache.setupInitializeHandler(buildStringCachingKey)
    }
    
    private func buildStringCachingKey() -> String {
        var resultString = ""
        
        resultString += methodType.rawValue
        resultString += apiMethod
        
        if let params = params {
            resultString += params.stringKey
        }
        
        if let headers = headers {
            resultString += headers.stringKey
        }
        
        return resultString
    }
}