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

public class ApiRequestBase<TResponse, TManager: ApiRequestManagerType>: RequestBase<TResponse, TManager>, _ApiRequestBase, CachingKeyProvider {
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
    
    private let cachingKeyValue = LazyValue<String>()
    
    public var cachingKey: String {
        return cachingKeyValue.value
    }
    
    public override func _requestEngine(manager: ManagerType) -> Observable<TResponse> {
        return manager.apiRequestEngine(self)
    }
    
    public override init() {
        super.init()
        cachingKeyValue.factory(buildCachingKey)
    }
    
    private func buildCachingKey() -> String {
        var resultString = ""
        
        resultString += methodType.rawValue
        resultString += method
        
        if let params = params {
            resultString += params.stringKey
        }
        
        if let headers = headers {
            resultString += headers.stringKey
        }
        
        return resultString
    }
}