//
//  AlamoRequestManager.swift
//  SomaKit
//
//  Created by Anton on 23.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift
import RxAlamofire
import Alamofire
import ObjectMapper

open class AlamoRequestManager: ApiRequestManagerType {
    fileprivate let sessionManager: SessionManager
    fileprivate let baseUrl: URLConvertible
    fileprivate let responseMapper: _StringMapperType
    
    public init(baseUrl: URLConvertible, sessionManager: SessionManager = SessionManager.default, responseMapper: _StringMapperType = JsonMapper()) {
        self.sessionManager = sessionManager
        self.baseUrl = baseUrl
        self.responseMapper = responseMapper
    }
    
    open func apiRequestEngine<TRequest: RequestType>(_ request: TRequest) -> Observable<TRequest.ResponseType> where TRequest: ApiParamsProvider {
        return Observable.deferred({ () -> Observable<TRequest.ResponseType> in
            let urlString = try self.buildURLString(request.method)
            let alamoMethodType = try self.alamoMethodType(request.methodType)
            return self.sessionManager.rx.string(alamoMethodType, urlString,
                parameters: request.params, encoding: self._parametersEncoding, headers: request.headers)
                .map({ (responseString) -> TRequest.ResponseType in
                    return try self.responseMapper.mapToModel(responseString)
                })
        })
    }
    
    open var _parametersEncoding: ParameterEncoding {
        return URLEncoding.default
    }
    
    fileprivate func buildURLString(_ endPoint: String) throws -> String {
        let url = URL(string: endPoint, relativeTo: baseUrl.url as URL?)
        
        if let url = url {
            return url.absoluteString
        }
        
        throw SomaError("URL building with endpoint \(endPoint) failed")
    }
    
    fileprivate func alamoMethodType(_ somaMethodType: ApiMethodType) throws -> HTTPMethod {
        guard let alamoMethod = HTTPMethod.init(rawValue: somaMethodType.rawValue) else {
            throw SomaError("Alamofire doesn't have api method type \(somaMethodType)")
        }
        
        return alamoMethod
    }
}
