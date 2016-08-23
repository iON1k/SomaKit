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

public typealias ApiParamsType = [String : AnyObject]
public typealias ApiHeadersType = [String : String]

public protocol _ApiRequestBase {
    var method: String { get }
    var methodType: ApiMethodType { get }
    var params: ApiParamsType? { get }
    var headers: ApiHeadersType? { get }
}

public protocol ApiRequestManagerType: RequestManagerType {
    func apiRequestEngine<TRequest: RequestType where TRequest: _ApiRequestBase>(request: TRequest) -> Observable<TRequest.ResponseType>
}

public class ApiRequestBase<TResponse, TManager: ApiRequestManagerType>: AbstractApiRequest<TResponse, TManager>, _ApiRequestBase, CachingKeyProvider {
    public typealias CachingKeyType = String
    
    public var method: String {
        Utils.abstractMethod()
    }
    
    public var methodType: ApiMethodType {
        Utils.abstractMethod()
    }
    
    public var params: ApiParamsType? {
        return nil
    }
    
    public var headers: ApiHeadersType? {
        return nil
    }
    
    public var cachingKey: CachingKeyType {
        return buildCachingKey()
    }
    
    public override func _requestEngine() -> Observable<TResponse> {
        return _manager.apiRequestEngine(self)
    }
    
    private func buildCachingKey() -> CachingKeyType {
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
    
    public func _shouldUseParamInCachingKey(paramName: String, paramValue: AnyObject) -> Bool {
        return true
    }
    
    public func _shouldUseHeaderParamInCachingKey(paramName: String, paramValue: String) -> Bool {
        return true
    }
}