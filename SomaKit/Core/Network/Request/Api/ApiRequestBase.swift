//
//  ApiRequestBase.swift
//  SomaKit
//
//  Created by Anton on 16.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public enum ApiMethodType: String {
    case OPTIONS, GET, HEAD, POST, PUT, PATCH, DELETE, TRACE, CONNECT
}

public typealias ApiParamsType = [String : Any]
public typealias ApiHeadersType = [String : String]

public protocol ApiParamsProvider {
    var method: String { get }
    var methodType: ApiMethodType { get }
    var params: ApiParamsType? { get }
    var headers: ApiHeadersType? { get }
}

public protocol ApiRequestManagerType: RequestManagerType {
    func apiRequestEngine<TRequest: RequestType>(_ request: TRequest) -> Observable<TRequest.ResponseType> where TRequest: ApiParamsProvider
}

open class ApiRequestBase<TResponse, TManager: ApiRequestManagerType>: AbstractApiRequest<TResponse, TManager>, ApiParamsProvider, StringCachingKeyProvider {
    open var method: String {
        Utils.abstractMethod()
    }
    
    open var methodType: ApiMethodType {
        Utils.abstractMethod()
    }
    
    open var params: ApiParamsType? {
        return nil
    }
    
    open var headers: ApiHeadersType? {
        return nil
    }
    
    open var stringCachingKey: String {
        return buildCachingKey()
    }
    
    open override func _requestEngine() -> Observable<TResponse> {
        return _manager.apiRequestEngine(self)
    }
    
    private func buildCachingKey() -> String {
        var resultString = ""
        
        resultString += methodType.rawValue
        resultString += method
        
        if let params = params {
            let filteredParams = params.filter({ (element) -> Bool in
                return self._shouldUseParamInCachingKey(element.0, paramValue: element.1)
            })
            
            resultString += filteredParams.stringKey
        }
        
        if let headers = headers {
            let filteredHeaderParams = headers.filter({ (element) -> Bool in
                return self._shouldUseHeaderParamInCachingKey(element.0, paramValue: element.1)
            })
            resultString += filteredHeaderParams.stringKey
        }
        
        return resultString
    }
    
    open func _shouldUseParamInCachingKey(_ paramName: String, paramValue: Any) -> Bool {
        return true
    }
    
    open func _shouldUseHeaderParamInCachingKey(_ paramName: String, paramValue: String) -> Bool {
        return true
    }
}
